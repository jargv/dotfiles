if window.get_active_title() == "Terminal":
    keyboard.send_keys("<super>+z")
else:
    keyboard.send_keys("<ctrl>+z")
