build:
	nim c -d:release  dynamic_theme
install:
	sudo cp dynamic_theme /usr/bin/
install_user_service:
	mkdir -p ${HOME}/.local/share/systemd/user
	cp dynamic_theme.service ${HOME}/.local/share/systemd/user
enable_service:
	systemctl --user enable dynamic_theme
	systemctl --user start dynamic_theme
