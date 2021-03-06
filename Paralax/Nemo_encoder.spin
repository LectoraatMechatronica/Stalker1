{{
*****************************************
*         Author: Karol Matusiak         *
*****************************************
 NSL   - enables SPI data transmition from register
 PCL  / - changes configuration value
 STCAL   - stores configuration to EEPROM 
}}

CON
    DIGITNUM = 16 'number of bits in Gray code that is use'     
    CONFIGURATION = 15 'number of configuration that is supposed to be saved - check documentation'
    CLKTIME = 150
     'Pin's numbers
    ''DOUT = 0   'Encoder's serial output'
    ''SCL = 1    'Encoder's serial clock'
    ''NSL = 2    'Encoder's serial controlling signal load/shift command'     
    ''KORR = 3  'Turns on/off correction of sent data (works only in 12-bits mode)' 
    ''PROBE_ON = 4'Turns on/off probe mode (configuration mode)'   
    ''PCL = 5 'Probe mode counter - select configuration to be saved'
    ''STCAL = 6 'applying configuration EPPROM' 
      
OBJ
  SPI   :       "SPI_Spin.spin"          


PUB Init(Dout,Scl,Nsl,Korr,Probe_on,Pcl,Stcal) 'initialization of SPI nad Serial'
   SPI.Start(CLKTIME,1)  
   DIRA[Dout] := 0  'setting pins as inputs/outputs'
   DIRA[Korr] := 1  
   DIRA[Scl] := 1
   DIRA[Nsl] := 1   
   DIRA[Probe_on] := 1
   DIRA[Pcl]:= 1
   DIRA[Stcal]:= 1    
  'Prepare the encodoer for first use on reading encoder counts' 
   outa[Nsl]:=1
   outa[Korr]:=1        
   outa[Probe_on]:= 1  'turning epprom config active'
   ''outa[STCAL]:=0   
   
   repeat CONFIGURATION  'clocking proper configuration '
      outa[Pcl]:= 0             
      outa[Pcl]:= 1
   outa[Stcal]:=1     
   outa[Stcal]:=0         'storing config, negative edge'    
   outa[Probe_on]:=0     'turning normal mode active'

                         
PUB ReadREG(Dout,Scl,Nsl) | data  'read value from nemo register'      
    ''dira[Nsl]:=1
    ''outa[Nsl]:=1
    ''outa[Nsl]:=0 
    data := SPI.SHIFTIN(Dout,Scl,SPI#MSBPOST,DIGITNUM, Nsl)  'most siginificant bit is sent first, word-lenght = DIGITNUM'    
    
    ''outa[Nsl]:=1   
    Return data  

PUB GrayToBin(GrayNum) | shift   'gray code to binary code conversion'
    shift := 1                                 
    repeat
      GrayNum ^= GrayNum >> shift 
       shift*=2
    while shift<DIGITNUM

    Return GrayNum                                         