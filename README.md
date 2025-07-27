# Ubuntu Initial Setup Script

A clean and customizable setup script to bootstrap development environments on **Ubuntu 22.04**.

This project includes:

- System updates and package installations
- Developer tools setup
- Git configuration
- Dotfiles and alias setup
- Optional GUI and personal tool configurations

---

## Project Structure
```
.
├── common/
│   ├── install_code_server.sh     # Installs VS Code Server
│   ├── install_dev_tools.sh       # Installs dev tools
│   └── install_packages.sh        # Installs APT packages
├── personal/
│   ├── d2coding_install.sh        # (Optional) Installs D2Coding font
│   ├── install_mavros.sh          # (Optional) ROS1 MAVROS installer
│   └── subl.sh                    # (Optional) Sublime Text launcher
├── to_copy/
│   ├── aliases                    # bash aliases
│   ├── ranger                     # ranger config
│   ├── tmux                       # tmux.conf
│   └── vim                        # vimrc
├── ubuntu_setup.sh               # Main setup script
├── LICENSE
└── README.md
```

---

## How to Use

> Do **NOT** run this script as `root`. It is intended to be run as a normal user.

```
git clone https://github.com/bwh1270/ubuntu_setup.git
cd ubuntu_setup
chmod +x ubuntu_setup.sh
./ubuntu_setup.sh
```

The script will:
1. Verify script location and permissions
2. Run system updates
3. Install packages and tools
4. Set up your Git identity
5. Copy `.vimrc`, `.tmux.conf`, `bash_aliases`, and `ranger` configs
6. Customize your terminal prompt (`~/.bashrc`)

You can modify or extend the following:
- `to_copy/` — include any dotfiles you want automatically copied
- `personal/` — add any personal scripts and call them from ubuntu_setup.sh
- `common/` — core installation logic is separated for modularity

### License
This project is licensed under the MIT License. See ```LICENSE``` for details.
