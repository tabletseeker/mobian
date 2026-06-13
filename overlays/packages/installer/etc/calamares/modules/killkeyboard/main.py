#!/usr/bin/env python3
import libcalamares
import subprocess

def run():
    """
    Terminates wvkbd cleanly right before the progress slideshow begins.
    """
    try:
        subprocess.run(["pkill", "-f", "wvkbd-mobintl"], check=False)
        libcalamares.utils.debug("wvkbd keyboard successfully terminated for slideshow.")
    except Exception as e:
        libcalamares.utils.warning(f"Could not kill wvkbd: {str(e)}")

    return None

