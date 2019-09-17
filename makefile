build:
	nim c -d:release  daynight_theme
install:
	sudo cp dynamic_theme /usr/bin/
install_user_service:
	mkdir -p ${HOME}/.local/share/systemd/user
	cp daynight_theme.service ${HOME}/.local/share/systemd/user
enable_service:
	systemctl --user enable daynight_theme
	systemctl --user start daynight_theme
