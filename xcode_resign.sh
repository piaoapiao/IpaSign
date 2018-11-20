# ${SRCROOT} 创建工程文件所在目录
TEMP_PATH="${SRCROOT}/Temp"

# 资源文件夹路径
ASSETS_PATH="${SRCROOT}/APP"

# 获取ipa包路径
TARGET_IPA_PATH="${ASSETS_PATH}/*.ipa"


# 新建temp文件夹
rm -rf "${SRCROOT}/Temp"
mkdir -p "${SRCROOT}/Temp"

#-------------------------------------
# 1.解压ipa到temp下
unzip -oqq "$TARGET_IPA_PATH" -d "$TEMP_PATH"
# 拿到解压的临时的app路径
TEMP_APP_PATH=$(set -- "$TEMP_PATH/Payload/"*.app;echo "$1")
# echo 路径是 "$TEMP_APP_PATH"


#-------------------------------------
# 2.将解压出来的.app拷贝到工程下
# BUILT_PRODUCTS_DIR 工程生成的app包路径
# TARGET_NAME target名称
TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
# 打印路径
# echo "app路径:$TARGET_APP_PATH"

rm -rf "$TARGET_APP_PATH"
mkdir -p "$TARGET_APP_PATH"
# 将TARGET_APP_PATH 路径拷贝到 TEMP_APP_PATH
cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH"


#-------------------------------------
# 3.删除extension(插件)和WatchAPP. 个人证书没法签名extension
rm -rf "$TARGET_APP_PATH/PlugIns"
rm -rf "$TARGET_APP_PATH/Watch"


#-------------------------------------
# 4.更新Info.plist文件, CFBundleIdentifier
#  设置:"Set : KEY Value" "目标文件路径"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"



#-------------------------------------
# 5.给mach-o文件开启执行权限
# 拿到Mach-o文件路径
APP_BINARY=`plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`
# 开启执行权限
chmod +x "$TARGET_APP_PATH/$APP_BINARY"


#-------------------------------------
# 6.重签名第三方 frameworks
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ];
then
for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
do


# 签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"

done
fi