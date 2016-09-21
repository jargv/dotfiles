if window.get_active_title() == "Terminal":
    keyboard.send_keys("<super>+c")
else:
    keyboard.send_keys("<ctrl>+c")
