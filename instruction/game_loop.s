# Within an infinite loop, the processor does the following;
#
# 1. update enemies' positions
# 2. update bullets' positions 
# 3. detect enemy+bullet collision and update accordingly 
# 4. detect enemy+ship collision and update accordingly
# 5. detect bullt+ship collsion and update accordingly
#
# $17: single entity ready to be written
# $18: entity position (x: [31:16] / y: [15:0]) 
# $19: entity dimension (width : [31:16] / height: [15:0])
# $20: entity type/index (type: [31:16] / index: [15:0])
# 
#
#

# initialization