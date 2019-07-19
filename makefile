build:
	nim c -d:release  dynamic_theme
install:
	sudo cp dynamic_theme /usr/bin/
install_service:
	sudo cp dynamic_theme.service /etc/systemd/system/
