## Board directory requirements

The directory structure for board should follow the following convention:

/boards/[target_board_name]/[build_env]

### target_board_name
Choose a target/board name that uniquely identifies the board, including required extension boards. For example: <b>UPDuino_v1</b> or <b>Terasic_DE0</b>

When an extension board is required, for instance, a VGAXYZ board, the target_board_name should be something like: <b>UPDuino_v1_VGAXYZ</b>

### build_env
Choose a build_env name that uniquely identifies the development environment, such as <b>yosys</b> or <b>quartus</b> or <b>webpackISE</b> etc.

### README.md
For each project, a README.md file should be present describing the hardware setup, the build environment and, if needed, the pinout used. Also include contact information of the maintainer.

Photos are a plus.