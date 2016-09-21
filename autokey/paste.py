if window.get_active_title() == "Terminal":
    keyboard.send_keys("<super>+v")
else:
    keyboard.send_keys("<ctrl>+v")
