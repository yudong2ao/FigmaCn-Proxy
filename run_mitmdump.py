import os
import sys
import traceback
import logging

sys.dont_write_bytecode = True

# Ensure stdout and stderr exist before ANY imports from mitmproxy
# because pythonw.exe doesn't provide them, which causes IocpProactor to crash
script_dir = os.path.dirname(os.path.abspath(__file__))
log_file = os.path.join(script_dir, "mitm_startup.log")

log_file_handle = open(log_file, "a", encoding="utf-8")
sys.stdout = log_file_handle
sys.stderr = log_file_handle
sys.stdin = open(os.devnull, "r")

logging.basicConfig(filename=log_file, level=logging.DEBUG, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

logging.info("Starting mitmdump wrapper script...")

try:
    import asyncio
    if sys.platform == 'win32':
        asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())
    from mitmproxy.tools.main import mitmdump
except BaseException as e:
    logging.error(f"Failed to import mitmdump: {e}\n{traceback.format_exc()}")
    sys.exit(1)

if __name__ == '__main__':
    
    try:
        figma_script = os.path.join(script_dir, "figma_zh_cn.py")
        if len(sys.argv) == 1:
            sys.argv.extend(["-s", figma_script, "-p", "8089", "-q"])
        
        logging.info(f"Arguments: {sys.argv}")
        sys.exit(mitmdump())
    except BaseException as e:
        logging.error(f"Error occurred: {str(e)}\n{traceback.format_exc()}")
        sys.exit(1)

