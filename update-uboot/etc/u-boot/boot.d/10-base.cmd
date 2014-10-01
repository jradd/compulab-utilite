setenv boot_disk sata
setenv boot_part 0

setenv load_img 'echo Loading ${boot_img}...; ext4load ${boot_disk} ${boot_part} ${img_addr} ${boot_img}; setenv booter ${booter} ${img_addr}'
setenv load_dtb 'echo Loading ${dtb}...; ext4load ${boot_disk} ${boot_part} ${dtb_addr} ${dtb}; setenv booter ${booter} - ${dtb_addr}'
setenv boot_prep 'run boot_base; setenv bootargs ${bootargs} ${boot_extra}; setenv bootcmd ${booter}'

