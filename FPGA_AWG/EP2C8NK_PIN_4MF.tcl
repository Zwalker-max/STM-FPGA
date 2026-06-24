# Pin Assignments for EEICST's EP2C8 NIOS2 Kernel Board
# 4MByte Flash (AM29LV320) Version
# Loywong, 2008.6.16

set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
set_global_assignment -name ENABLE_INIT_DONE_OUTPUT OFF

set_location_assignment PIN_91  -to CLK_50M
set_location_assignment PIN_90  -to nReset

###### Alternate with P[2..9] ####################
set_location_assignment PIN_17  -to KEY[0]
set_location_assignment PIN_18  -to KEY[1]
set_location_assignment PIN_21  -to KEY[2]
set_location_assignment PIN_22  -to KEY[3]
set_location_assignment PIN_24  -to LED[0]
set_location_assignment PIN_25  -to LED[1]
set_location_assignment PIN_28  -to LED[2]
set_location_assignment PIN_30  -to LED[3]
##################################################

set_location_assignment PIN_8   -to P[0]
set_location_assignment PIN_9   -to P[1]

###### Alternate with KEY & LED ##################
#set_location_assignment PIN_17  -to P[2]
#set_location_assignment PIN_18  -to P[3]
#set_location_assignment PIN_21  -to P[4]
#set_location_assignment PIN_22  -to P[5]
#set_location_assignment PIN_24  -to P[6]
#set_location_assignment PIN_25  -to P[7]
#set_location_assignment PIN_28  -to P[8]
#set_location_assignment PIN_30  -to P[9]
##################################################

set_location_assignment PIN_31  -to P[10]
set_location_assignment PIN_32  -to P[11]
set_location_assignment PIN_40  -to P[12]
set_location_assignment PIN_41  -to P[13]
set_location_assignment PIN_42  -to P[14]
set_location_assignment PIN_43  -to P[15]
set_location_assignment PIN_44  -to P[16]
set_location_assignment PIN_45  -to P[17]
set_location_assignment PIN_47  -to P[18]
set_location_assignment PIN_48  -to P[19]
set_location_assignment PIN_51  -to P[20]
set_location_assignment PIN_52  -to P[21]
set_location_assignment PIN_53  -to P[22]
set_location_assignment PIN_55  -to P[23]
set_location_assignment PIN_57  -to P[24]
set_location_assignment PIN_58  -to P[25]

set_location_assignment PIN_73  -to SDR_FLA_DQ[15]
set_location_assignment PIN_74  -to SDR_FLA_DQ[14]
set_location_assignment PIN_75  -to SDR_FLA_DQ[13]
set_location_assignment PIN_76  -to SDR_FLA_DQ[12]
set_location_assignment PIN_79  -to SDR_FLA_DQ[11]
set_location_assignment PIN_86  -to SDR_FLA_DQ[10]
set_location_assignment PIN_87  -to SDR_FLA_DQ[9]
set_location_assignment PIN_92  -to SDR_FLA_DQ[8]
set_location_assignment PIN_133 -to SDR_FLA_DQ[7]
set_location_assignment PIN_134 -to SDR_FLA_DQ[6]
set_location_assignment PIN_135 -to SDR_FLA_DQ[5]
set_location_assignment PIN_136 -to SDR_FLA_DQ[4]
set_location_assignment PIN_137 -to SDR_FLA_DQ[3]
set_location_assignment PIN_139 -to SDR_FLA_DQ[2]
set_location_assignment PIN_141 -to SDR_FLA_DQ[1]
set_location_assignment PIN_142 -to SDR_FLA_DQ[0]

set_location_assignment PIN_63  -to SDR_FLA_A[21]
set_location_assignment PIN_64  -to SDR_FLA_A[20]
set_location_assignment PIN_4   -to SDR_FLA_A[19]
set_location_assignment PIN_3   -to SDR_FLA_A[18]
set_location_assignment PIN_72  -to SDR_FLA_A[17]
set_location_assignment PIN_71  -to SDR_FLA_A[16]
set_location_assignment PIN_70  -to SDR_FLA_A[15]
set_location_assignment PIN_69  -to SDR_FLA_A[14]
set_location_assignment PIN_67  -to SDR_FLA_A[13]
set_location_assignment PIN_65  -to SDR_FLA_A[12]
set_location_assignment PIN_101 -to SDR_FLA_A[11]
set_location_assignment PIN_122 -to SDR_FLA_A[10]
set_location_assignment PIN_100 -to SDR_FLA_A[9]
set_location_assignment PIN_99  -to SDR_FLA_A[8]
set_location_assignment PIN_97  -to SDR_FLA_A[7]
set_location_assignment PIN_96  -to SDR_FLA_A[6]
set_location_assignment PIN_94  -to SDR_FLA_A[5]
set_location_assignment PIN_93  -to SDR_FLA_A[4]
set_location_assignment PIN_132 -to SDR_FLA_A[3]
set_location_assignment PIN_129 -to SDR_FLA_A[2]
set_location_assignment PIN_126 -to SDR_FLA_A[1]
set_location_assignment PIN_125 -to SDR_FLA_A[0]

set_location_assignment PIN_121 -to SDR_BA[1]
set_location_assignment PIN_120 -to SDR_BA[0]
set_location_assignment PIN_112 -to SDR_DQM[1]
set_location_assignment PIN_113 -to SDR_DQM[0]
set_location_assignment PIN_118 -to SDR_nRAS
set_location_assignment PIN_115 -to SDR_nCAS
set_location_assignment PIN_114 -to SDR_nWE
set_location_assignment PIN_119 -to SDR_nCS
set_location_assignment PIN_104 -to SDR_CLK
set_location_assignment PIN_103 -to SDR_CKE

set_location_assignment PIN_144 -to FLA_nCE
set_location_assignment PIN_143 -to FLA_nOE
set_location_assignment PIN_60  -to FLA_nWE
set_location_assignment PIN_59  -to FLA_nRESET
set_location_assignment PIN_7   -to FLA_RY_nBY
