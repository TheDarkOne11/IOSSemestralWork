COMMITS=`git rev-list HEAD --count`
HEADER_FILE="$PROJECT_DIR/info_preprocess_header.h"

echo "// Auto-generated" > $HEADER_FILE
echo "" >> $HEADER_FILE
echo "#define BUILD_NUMBER $COMMITS" >> $HEADER_FILE
