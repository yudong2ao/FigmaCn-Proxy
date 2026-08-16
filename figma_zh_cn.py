from mitmproxy import http
import re

# 正则匹配 Figma 请求英文语言包的 URL
TARGET_URL = "https://kailous.github.io/figma-zh-CN-localized/lang/zh.json"
PATTERN = re.compile(r"^https://www\.figma\.com/webpack-artifacts/assets/figma_app(?:_beta|__rspack)?-[a-f0-9]+\.min\.en\.json(?:\.br)?$")

def request(flow: http.HTTPFlow) -> None:


    # 如果 URL 匹配到了官方英文语言包
    if PATTERN.match(flow.request.url):
        # 拦截该请求，并直接返回 HTTP 307 重定向到中文语言包地址
        flow.response = http.Response.make(
            307,
            b"",
            {"Location": TARGET_URL}
        )

