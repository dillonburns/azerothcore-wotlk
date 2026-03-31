#!/usr/bin/env python3
import re
from pathlib import Path


workspace = Path(__file__).resolve().parents[1]
lua_functions_cpp = workspace / "modules/mod-ale/src/LuaEngine/LuaFunctions.cpp"
global_methods_h = workspace / "modules/mod-ale/src/LuaEngine/methods/GlobalMethods.h"
out = workspace / "tools/mod_ale_api.lua"


TYPE_MAP = {
    "uint8": "integer",
    "uint16": "integer",
    "uint32": "integer",
    "uint64": "integer",
    "int8": "integer",
    "int16": "integer",
    "int32": "integer",
    "int64": "integer",
    "int": "integer",
    "float": "number",
    "double": "number",
    "bool": "boolean",
    "string": "string",
    "function": "function",
    "...": "any",
}


def sanitize_name(name: str) -> str:
    n = name.strip()
    if not n:
        return "arg"
    if n == "function":
        return "callback"
    if n in {"end", "local", "repeat", "until"}:
        return f"{n}_"
    return re.sub(r"[^A-Za-z0-9_]", "_", n)


def map_type(raw_type: str) -> str:
    t = raw_type.strip()
    if t.startswith("[") and t.endswith("]"):
        return "any"
    return TYPE_MAP.get(t, "any")


def parse_global_method_names(cpp_text: str) -> list[str]:
    table = re.search(r"luaL_Reg\s+GlobalMethods\[\]\s*=\s*\{(.*?)\n\};", cpp_text, re.S)
    if not table:
        raise SystemExit("Could not locate GlobalMethods table in LuaFunctions.cpp")

    names: list[str] = []
    for name in re.findall(r'\{\s*"([A-Za-z0-9_]+)"\s*,\s*&LuaGlobalFunctions::', table.group(1)):
        if name not in names:
            names.append(name)
    return names


def parse_comment_blocks(header_text: str) -> dict[str, str]:
    blocks: dict[str, str] = {}
    pattern = re.compile(r"/\*\*(.*?)\*/\s*int\s+(\w+)\s*\(lua_State\*\s*L\)", re.S)
    for body, fn_name in pattern.findall(header_text):
        blocks[fn_name] = body
    return blocks


def parse_proto_line(proto: str) -> tuple[list[str], list[str]]:
    raw = proto.strip()
    if "=" in raw:
        lhs, rhs = raw.split("=", 1)
        returns = [sanitize_name(x) for x in lhs.split(",") if x.strip()]
        call = rhs.strip()
    else:
        returns = []
        call = raw

    m = re.match(r"\((.*)\)", call)
    params = []
    if m:
        params = [sanitize_name(x) for x in m.group(1).split(",") if x.strip()]
    return returns, params


def parse_param_lines(block: str) -> list[tuple[str, str, bool]]:
    parsed: list[tuple[str, str, bool]] = []
    rx = re.compile(r"^\s*\*\s*@param\s+([^\s]+)\s+(\w+)(?:\s*=\s*[^\s:]+)?", re.M)
    optional_rx = re.compile(r"^\s*\*\s*@param\s+([^\s]+)\s+(\w+)\s*=\s*[^\s:]+", re.M)

    optional = {name for _, name in optional_rx.findall(block)}
    for p_type, p_name in rx.findall(block):
        parsed.append((sanitize_name(p_name), map_type(p_type), p_name in optional))
    return parsed


def build_overload(params: list[tuple[str, str, bool]], returns: list[str]) -> str:
    if params:
        parts = []
        for name, p_type, is_optional in params:
            suffix = "?" if is_optional else ""
            parts.append(f"{name}{suffix}: {p_type}")
        args = ", ".join(parts)
    else:
        args = ""

    ret = "function" if any(r == "cancel" for r in returns) else "any"
    return f"---@overload fun({args}): {ret}"


cpp_text = lua_functions_cpp.read_text(encoding="utf-8")
header_text = global_methods_h.read_text(encoding="utf-8")

global_names = parse_global_method_names(cpp_text)
doc_blocks = parse_comment_blocks(header_text)

lines = [
    "---@meta",
    "",
    "-- Generated from mod-ale bindings and docs.",
    "-- Sources:",
    "--   modules/mod-ale/src/LuaEngine/LuaFunctions.cpp",
    "--   modules/mod-ale/src/LuaEngine/methods/GlobalMethods.h",
    "-- Regenerate with: python3 tools/gen_mod_ale_lua_stubs.py",
    "",
]

for fn_name in global_names:
    block = doc_blocks.get(fn_name, "")
    proto_lines = re.findall(r"^\s*\*\s*@proto\s+(.+)$", block, re.M)
    param_info = parse_param_lines(block)

    if proto_lines:
        for p in proto_lines:
            returns, p_names = parse_proto_line(p)
            merged = []
            for p_name in p_names:
                matched = next((item for item in param_info if item[0] == p_name), None)
                if matched:
                    merged.append(matched)
                else:
                    merged.append((p_name, "any", False))
            lines.append(build_overload(merged, returns))
    elif param_info:
        lines.append(build_overload(param_info, []))

    lines.append("---@diagnostic disable-next-line: duplicate-set-field")
    lines.append(f"function {fn_name}(...) end")
    lines.append("")

out.write_text("\n".join(lines), encoding="utf-8")
print(f"Wrote {out} with {len(global_names)} global functions")
