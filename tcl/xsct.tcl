setws ./workspace
app create -name test_project -hw ./dist/design_1_wrapper.xsa -os standalone -proc ps7_cortexa9_0 -template {Hello World}
# app create -name test_project -hw ./dist/design_1_wrapper.xsa -os standalone -proc ps7_cortexa9_0 -template {Empty Application(C)}


app build -name test_project
# Build the system project. This builds the platform project to generate fsbl.elf
# and creates a bif file and runs Bootgen to create a boot image (BOOT.BIN)
sysproj build -name test_project