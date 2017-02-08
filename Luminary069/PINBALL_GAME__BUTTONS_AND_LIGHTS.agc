### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    PINBALL_GAME__BUTTONS_AND_LIGHTS.agc
## Purpose:     The main source file for Luminary revision 069.
##              It is part of the source code for the original release
##              of the flight software for the Lunar Module's (LM) Apollo
##              Guidance Computer (AGC) for Apollo 10. The actual flown
##              version was Luminary 69 revision 2, which included a
##              newer lunar gravity model and only affected module 2.
##              This file is intended to be a faithful transcription, except
##              that the code format has been changed to conform to the
##              requirements of the yaYUL assembler rather than the
##              original YUL assembler.
## Reference:   pp. 403-484
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2016-12-13 MAS  Created from Luminary 99.
##              2016-12-14 MAS  Updated from comment-proofed Luminary 99 version.
##              2017-01-21 MAS  Updated for Luminary 69.
##		2017-01-27 RSB	Proofed comment text using octopus/prooferComments
##				but no errors found.
##		2017-01-28 RSB	WTIH -> WITH.
##		2017-02-08 RSB	Comment-text fixes identified while proofing Artemis 72.

## Page 403
# PROGRAM NAME - KEYBOARD AND DISPLAY PROGRAM
# MOD NO - 4      DATE - 27 APRIL 1967      ASSEMBLY - PINDANCE REV 18
# MOD BY - FILENE
# LOG SECTION - PINBALL GAME  BUTTONS AND LIGHTS

# FUNCTIONAL DESCRIPTION-

#    THE KEYBOARD AND DISPLAY SYSTEM PROGRAM OPERATES UNDER EXECUTIVE
# CONTROL AND PROCESSES INFORMATION EXCHANGED BETWEEN THE AGC AND THE
# COMPUTER OPERATOR.  THE INPUTS TO THE PROGRAM ARE FROM THE KEYBOARD,
# FROM INTERNAL PROGRAMS, AND FROM THE UPLINK.
#    THE LANGUAGE OF COMMUNICATION WITH THE PROGRAM IS A PAIR OF WORDS
# KNOWN AS VERB AND NOUN.  EACH OF THESE IS REPRESENTED BY A 2 CHARACTER
# DECIMAL NUMBER.  THE VERB CODE INDICATES WHAT ACTION IS TO BE TAKEN, THE
# NOUN CODE INDICATES TO WHAT THIS ACTION IS APPLIED.  NOUNS USUALLY
# REFER TO A GROUP OF ERASABLE REGISTERS.

# VERBS ARE GROUPED INTO DISPLAYS, LOADS, MONITORS (DISPLAYS THAT ARE
# UPDATED ONCE PER SECOND), SPECIAL FUNCTIONS, AND EXTENDED VERBS(THESE
# ARE OUTSIDE OF THE DOMAIN OF PINBALL AND CAN BE FOUND UNDER LOG SECTION
# :EXTENDED VERBS:).
# A LIST OF VERBS AND NOUNS IS GIVEN IN LOG SECTION :ASSEMBLY AND 
# OPERATION INFORMATION:.

## Ram&oacute;n Alonso, one of the original AGC developers, provides a 
## little more insight:  Apparently, nobody had yet arrived at any kind 
## of software requirements for the AGC's user interface when the desire
## arose within the Instrumentation Laboratory to set up a demo 
## guidance-computer unit with which to impress visitors to the lab.  
## Of course, this demo would have to <i>do</i> something, if it was going to be 
## at all impressive, and to do something it would need some software. In 
## short order, some of the coders threw together a demo program, 
## inventing and using the verb/noun user-interface concept (in the 
## whimsical fashion seen in much of this code), but without any idea 
## that the verb/noun concept would somehow survive into the flight 
## software.  As time passed, and more and more people became familiar 
## with the demo, nobody got around to inventing an improvement for the 
## user interface, so the coders simply built it into the flight software 
## without any specific requirements to do so.<br>
## <br>
## However, that does not mean that the verb/noun interface was universally 
## beloved.  Ram&oacute;n says that <i>many</i> objections were received from 
## naysayers, such as "it's not scientific", "it's not dignified", or 
## even "astronauts won't understand it".  Even though the coders of 
## the demo hadn't seriously intended the verb/noun interface to be used 
## in any permanent way, it became a kind of devilish game to counter 
## these objections with (perhaps) sophistic arguments as to why the 
## interface was really a good one.  In the end, the coders won.  I don't 
## know whether they were elated or dismayed by this victory.<br>
## <br>
## The astronauts, of course, <i>could</i> understand the interface, 
## but they did not like it.  Most of them really wanted an interface much 
## more like that they had used in aircraft:  i.e., lots of dials and 
## switches.  Dave Scott is the the only astronaut I'm aware of who had 
## kind words for it (or for the AGC in general), though we are told that 
## Jim McDivitt wasn't necessary completely hostile to it.<br>
## <br>
## <div style="text-align: right;"><small>&mdash;Ron Burkey, 07/2009</small></div>

# CALLING SEQUENCES-

# KEYBOARD:
#    EACH DEPRESSION OF A KEYBOARD BUTTON ACTIVATES INTERRUPT KEYRUPT1
# AND PLACES THE 5 BIT KEY CODE INTO CHANNEL 15.  KEYRUPT1 PLACES THE KEY
# CODE INTO MPAC, ENTERS AN EXECUTIVE REQUEST FOR THE KEYBOARD AND DISPLAY
# PROGRAM (AT :CHARIN:), AND EXECUTES A RESUME.

# UPLINK:
#    EACH WORD RECEIVED BY THE UPLINK ACTIVATES INTERRUPT UPRUPT WHICH
# PLACES THE 5 BIT KEY CODE INTO MPAC, ENTERS AN EXECUTIVE REQUEST FOR THE
# KEYBOARD AND DISPLAY PROGRAM (AT:CHARIN:) AND EXECUTES A RESUME.

# INTERNAL PROGRAMS:
#    INTERNAL PROGRAMS CALL PINBALL AT :NVSUB: WITH THE DESIRED VERB/NOUN
# CODE IN A (LOW 7 BITS FOR NOUN, NEXT 7 BITS FOR VERB).  DETAILS
# DESCRIBED ON REMARKS CARDS JUST BEFORE :NVSUB: AND :NVSBWAIT: (SEE
# SYMBOL TABLE FOR PAGE NUMBERS).

# NORMAL EXIT MODES -
#    IF PINBALL WAS CALLED BY EXTERNAL ACTION, THERE ARE FOUR EXITS:
#          1) ALL BUT (2), (3), AND (4) EXIT DIRECTLY TO ENDOFJOB.
#          2) EXTENDED VERBS GO TO THE EXTENDED VERB FAN AS PART OF THE
## Page 404
#             PINBALL EXECUTIVE JOB WITH PRIORITY 30000.  IT IS THE 
#             RESPONSIBILITY OF THE EXTENDED VERB CALLED TO EVENTUALLY
#             CHANGE PRIORITY (IF NECESSARY) AND DO AN ENDOFJOB.
#             ALSO PINBALL IS A NOVAC JOB. EBANK SET FOR COMMON.
#          3) VERB 37. CHANGE OF PROGRAM (MAJOR MODE) CALLS :V37: IN THE
#             SERVICE ROUTINES AS PART OF THE PINBALL EXEC JOB WITH PRIO
#             30000.  THE NEW PROGRAM CODE (MAJOR MODE) IS LEFT IN A.
#          4) KEY RELEASE BUTTON CALLS :PINBRNCH: IN THE DISPLAY INTERFACE
#             ROUTINES AS PART OF THE PINBALL EXEC JOB WITH PRIO 30000 IF 
#             THE KEY RELEASE LIGHT IS OFF AND :CADRSTOR: IS NOT +0.

#    IF PINBALL WAS CALLED BY INTERNAL PROGRAMS, EXIT FROM PINBALL IS BACK
# TO CALLING ROUTINE.  DETAILS DESCRIBED IN REMARKS CARDS JUST BEFORE
# :NVSUB: AND :NVSBWAIT: (SEE SYMBOL TABLE FOR PAGE NUMBERS).


# ALARM OR ABORT EXIT MODES-

# EXTERNAL INITIATION:
#    IF SOME IMPROPER SEQUENCE OF KEY CODES IS DETECTED, THE OPERATOR
# ERROR LIGHT IS TURNED ON AND EXIT IS TO :ENDOFJOB:.

# INTERNAL PROGRAM INITIATION:
#    IF AN ILLEGAL V/N COMBINATION IS ATTEMPTED, AN ABORT IS CAUSED
# (WITH OCTAL 01501).
#    IF A SECOND ATTEMPT IS MADE TO GO TO SLEEP IN PINBALL, AN ABORT IS
# CAUSED (WITH OCTAL 01206). THERE ARE TWO WAYS TO GO TO SLEEP IN PINBALL:
#          1) ENDIDLE OR DATAWAIT.
#          2) NVSBWAIT, PRENVBSY, OR NVSUBUSY.

# CONDITIONS LEADING TO THE ABOVE ARE DESCRIBED IN FORTHCOMING MIT/IL
# E-REPORT DESCRIBING KEYBOARD AND DISPLAY OPERATION FOR 278.


# OUTPUT-

#    INFORMATION TO BE SENT TO THE DISPLAY PANEL IS LEFT IN THE :DSPTAB:
# BUFFERS REGISTERS (UNDER EXEC CONTROL).  :DSPOUT: (A PART OF T4RUPT)
# HANDLES THE PLACING OF THE :DSPTAB: INFORMATION INTO OUTPUT CHANNEL 10
# IN INTERRUPT.


# ERASABLE INITIALIZATION-

#    FRESH START AND RESTART INITIALIZE THE NECESSARY E REGISTERS FOR
# PINBALL IN :STARTSUB:.   REGISTERS ARE:  DSPTAB BUFFER, CADRSTOR,
# REQRET, CLPASS, DSPLOCK, MONSAVE, MONSAVE1, VERBREG, NOUNREG, DSPLIST,
# DSPCOUNT, NOUT.

# A COMPLETE LIST OF ALL THE ERASABLES (BOTH RESERVED AND TEMPORARIES) FOR
## Page 405
# PINBALL IS GIVEN BELOW.


# THE FOLLOWING ARE OF GENERAL INTEREST-

#    REMARKS CARDS PRECEDE THE REFERENCED SYMBOL DEFINITION.  SEE SYMBOL
# TABLE TO FIND APPROPRIATE PAGE NUMBERS.

#    NVSUB   CALLING POINT FOR INTERNAL USE OF PINBALL.
#              OF RELATED INTEREST   NVSBWAIT
#                                    NVSUBUSY
#                                    PRENVBSY

#    ENDIDLE   ROUTINE FOR INTERNAL PROGRAMS WISHING TO GO TO SLEEP WHILE
#              AWAITING OPERATORS RESPONSE.

#    DSPMM   ROUTINE BY WHICH AN INTERNAL PROGRAM MAY DISPLAY A DECIMAL
#            PROGRAM CODE (MAJOR MODE) IN THE PROGRAM (MAJOR MODE) LIGHTS.
#            (DSPMM DOES NOT DISPLAY DIRECTLY BUT ENTERS EXEC REQUEST
#            FOR DSPMMJB WITH PRIO 30000 AND RETURNS TO CALLER.)

#    BLANKSUB   ROUTINE BY WHICH AN INTERNAL PROGRAM MAY BLANK ANY
#               COMBINATION OF THE DISPLAY REGISTERS R1, R2, R3.

#    JAMTERM   ROUTINES BY WHICH AN INTERNAL PROGRAM MAY PERFORM THE
#    JAMPROC   TERMINATE (V 34) OR PROCEED (V 33) FUNCTION.

#    MONITOR   VERBS FOR PERIODIC ( 1 PER SEC) DISPLAY.

#    PLEASE PERFORM, PLEASE MARK SITUATIONS
#                 REMARKS DESCRIBING HOW AN INTERNAL ROUTINE SHOULD HANDLE
#                 THESE SITUATIONS CAN BE FOUND JUST BEFORE :NVSUB: (SEE
#                 SYMBOL TABLE FOR PAGE NUMBER).

#    THE NOUN TABLE FORMAT IS DESCRIBED ON A PAGE OF REMARKS CARDS JUST
#    BEFORE :DSPABC: (SEE SYMBOL TABLE FOR PAGE NUMBER).

#    THE NOUN TABLES THEMSELVES ARE FOUND IN LOG SECTION :PINBALL NOUN
#    TABLES:.


# FOR FURTHER DETAILS ABOUT OPERATION OF THE KEYBOARD AND DISPLAY SYSTEM
# PROGRAM, SEE THE MISSION PLAN AND/OR MIT/IL E-2129
# DESCRIBING KEYBOARD AND DISPLAY OPERATION FOR 278.

## The document described above, "Keyboard and Display Program Operation"
## by Alan I. Green and Robert J. Filene is 
## <a href="http://www.ibiblio.org/apollo/hrst/archive/1706.pdf">
## available online at the Virtual AGC website</a>.
## <small>&mdash;Ron Burkey, 07/2009</small>

# THE FOLLOWING QUOTATION IS PROVIDED THROUGH THE COURTESY OF THE AUTHORS.
#
#       ::IT WILL BE PROVED TO THY FACE THAT THOU HAST MEN ABOUT THEE THAT
# USUALLY TALK OF A NOUN AND A VERB, AND SUCH ABOMINABLE WORDS AS NO
## Page 406
# CHRISTIAN EAR CAN ENDURE TO HEAR.::

#                      HENRY 6, ACT 2, SCENE 4

## Actually, this quotation is from <i>Henry VI</i>, Part 2, Act IV, Scene VII.
## <small>&mdash;Ron Burkey, 07/2009</small>

# THE FOLLOWING ASSIGNMENTS FOR PINBALL ARE MADE ELSEWHERE


# RESERVED FOR PINBALL EXECUTIVE ACTION

# DSPCOUNT ERASE                  DISPLAY POSITION INDICATOR
# DECBRNCH ERASE                  +DEC, - DEC, OCT INDICATOR
# VERBREG  ERASE                  VERB CODE
# NOUNREG  ERASE                  NOUN CODE
# XREG     ERASE                  R1 INPUT BUFFER
# YREG     ERASE                  R2 INPUT BUFFER
# ZREG     ERASE                  R3 INPUT BUFFER
# XREGLP   ERASE                  LO PART OF XREG (FOR DEC CONV ONLY)
# YREGLP   ERASE                  LO PART OF YREG (FOR DEC CONV ONLY)
# HITEMOUT =      YREGLP          TEMP FOR DISPLAY OF HRS, MIN, SEC
#                                          MUST = LOTEMOUT-1.
# ZREGLP   ERASE                  LO PART OF ZREG (FOR DEC CONV ONLY)
# LOTEMOUT =      ZREGLP          TEMP FOR DISPLAY OF HRS, MIN, SEC
#                                          MUST = HITEMOUT+1.
# MODREG   ERASE                  MODE CODE
# DSPLOCK  ERASE                  KEYBOARD/SUBROUTINE CALL INTERLOCK
# REQRET   ERASE                  RETURN REGISTER FOR LOAD
# LOADSTAT ERASE                  STATUS INDICATOR FOR LOADTST
# CLPASS   ERASE                  PASS INDICATOR CLEAR
# NOUT     ERASE                  ACTIVITY COUNTER FOR DSPTAB
# NOUNCADR ERASE                  MACHINE CADR FOR NOUN
# MONSAVE  ERASE                  N/V CODE FOR MONITOR. (= MONSAVE1-1)
# MONSAVE1 ERASE                  NOUNCADR FOR MONITOR (MATBS) =MONSAVE+1
# MONSAVE2 ERASE                  NVMONOPT OPTIONS
# DSPTAB   ERASE          +13D    0-10,DISPLAY PANEL BUFFER,11-13,C RELAYS
# CADRSTOR ERASE                  ENDIDLE STORAGE
# NVQTEM   ERASE                  NVSUB STORAGE FOR CALLING ADDRESS
#                                 MUST = NVBNKTEM-1
# NVBNKTEM ERASE                  NVSUB STORAGE FOR CALLING BANK
#                                 MUST = NVQTEM+1
# VERBSAVE ERASE                  NEEDED FOR RECYCLE
# DSPLIST  ERASE                  WAITING REG FOR DSP SYST INTERNAL USE
# EXTVBACT REASE                  EXTENDED VERB ACTIVITY INTERLOCK
# DSPTEM1  ERASE          +2      BUFFER STORAGE AREA 1 (MOSTLY FOR TIME)
# DSPTEM2  ERASE          +2      BUFFER STORAGE AREA 2 (MOSTLY FOR DEG)
# END OF ERASABLES RESERVED FOR PINBALL EXECUTIVE ACTION


# TEMPORARIES FOR PINBALL EXECUTIVE ACTION

## Page 407
# DSEXIT   =      INTB15+         RETURN FOR DSPIN
# EXITEM   =      INTB15+         RETURN FOR SCALE FACTOR ROUTINE SELECT
# BLANKRET =      INTB15+         RETURN FOR 2BLANK

# WRDRET   =      INTBIT15        RETURN FOR 5BLANK
# WDRET    =      INTBIT15        RETURN FOR DSPWD
# DECRET   =      INTBIT15        RETURN FOR PUTCOM(DEC LOAD)
# 21/22REG =      INTBIT15        TEMP FOR CHARIN

# UPDATRET =      POLISH          RETURN FOR UPDATNN, UPDATVB
# CHAR     =      POLISH          TEMP FOR CHARIN
# ERCNT    =      POLISH          COUNTER FOR ERROR LIGHT RESET
# DECOUNT  =      POLISH          COUNTER FOR SCALING AND DISPLAY (DEC)

# SGNON    =      VBUF            TEMP FOR +,- ON
# NOUNTEM  =      VBUF            COUNTER FOR MIXNOUN FETCH
# DISTEM   =      VBUF            COUNTER FOR OCTAL DISPLAY VERBS
# DECTEM   =      VBUF            COUNTER FOR FETCH (DEC DISPLAY VERBS)

# SGNOFF   =      VBUF    +1      TEMP FOR +,- ON
# NVTEMP   =      VBUF    +1      TEMP FOR NVSUB
# SFTEMP1  =      VBUF    +1      STORAGE FOR SF CONST HI PART(=SFTEMP2-1)
# HITEMIN  =      VBUF    +1      TEMP FOR LOAD OF HRS, MIN, SEC
#                                          MUST = LOTEMIN-1.
# CODE     =      VBUF    +2      FOR DSPIN
# SFTEMP2  =      VBUF    +2      STORAGE FOR SF CONST LO PART(=SFTEMP1+1)
# LOTEMIN  =      VBUF    +2      TEMP FOR LOAD OF HRS, MIN, SEC
#                                          MUST = HITEMIN+1.
# MIXTEMP  =      VBUF    +3      FOR MIXNOUN DATA
# SIGNRET  =      VBUF    +3      RETURN FOR +,- ON

# ALSO MIXTEMP+1 = VBUF+4, MIXTEMP+2 = VBUF+5.

# ENTRET   =      DOTINC          EXIT FROM ENTER

# WDCNT    =      DOTRET          CHAR COUNTER FOR DSPWD
# INREL    =      DOTRET          INPUT BUFFER SELECTOR ( X,Y,Z, REG )

# DSPMMTEM =      MATINC          DSPCOUNT SAVE FOR DSPMM
# MIXBR    =      MATINC          INDICATOR FOR MIXED OR NORMAL NOUN

# TEM1     ERASE                  EXEC TEMP
# DSREL    =      TEM1            REL ADDRESS FOR DSPIN

# TEM2     ERASE                  EXEC TEMP
# DSMAG    =      TEM2            MAGNITUDE STORE FOR DSPIN
# IDADDTEM =      TEM2            MIXNOUN INDIRECT ADDRESS STORAGE

# TEM3     ERASE                  EXEC TEMP
# COUNT    =      TEM3            FOR DSPIN

## Page 408
# TEM4     ERASE                  EXEC TEMP
# LSTPTR   =      TEM4            LIST POINTER FOR GRABUSY
# RELRET   =      TEM4            RETURN FOR RELDSP
# FREERET  =      TEM4            RETURN FOR FREEDSP
# DSPWDRET =      TEM4            RETURN FOR DSPSIGN
# SEPSCRET =      TEM4            RETURN FOR SEPSEC
# SEPMNRET =      TEM4            RETURN FOR SEPMIN

# TEM5     ERASE                  EXEC TEMP
# NOUNADD  =      TEM5            TEMP STORAGE FOR NOUN ADDRESS

# NNADTEM  ERASE                  TEMP FOR NOUN ADDRESS TABLE ENTRY
# NNTYPTEM ERASE                  TEMP FOR NOUN TYPE TABLE ENTRY
# IDAD1TEM ERASE                  TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
#                                 MUST = IDAD2TEM-1, = IDAD3TEM-2.
# IDAD2TEM ERASE                  TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
#                                 MUST = IDAD1TEM+1, = IDAD3TEM-1.
# IDAD3TEM ERASE                  TEMP FOR INDIR ADRESS TABLE ENTRY(MIXNN)
#                                 MUST = IDAD1TEM+2, = IDAD2TEM+1.
# RUTMXTEM ERASE                  TEMP FOR SF ROUT TABLE ENTRY(MIXNN ONLY)
# END OF TEMPORARIES FOR PINBALL EXECUTIVE ACTION


# ADDITIONAL TEMPORARIES FOR PINBALL EXECUTIVE ACTION

# MPAC, THRU MPAC +6
# BUF, +1, +2
# BUF2, +1, +2
# MPTEMP
# ADDRWD
#   END OF ADDITIONAL TEMPS FOR PINBALL EXEC ACTION


# RESERVED FOR PINBALL INTERRUPT ACTION

# DSPCNT   ERASE                  COUNTER FOR DSPOUT
# UPLOCK   ERASE                  BIT1 = UPLINK INTERLOCK (ACTIVATED BY
#                                                                         RECEPTION OF A BAD MESSAGE IN UPLINK)
# END OF ERASABLES RESERVED FOR PINBALL INTERRUPT ACTION


# TEMPORARIES FOR PINBALL INTERRUPT ACTION
#
# KEYTEMP1 =      WAITEXIT        TEMP FOR KEYRUPT, UPRUPT
# DSRUPTEM =      WAITEXIT        TEMP FOR DSPOUT
# KEYTEMP2 =      RUPTAGN         TEMP FOR KEYRUPT, UPRUPT
# END OF TEMPORARIES FOR PINBALL INTERRUPT ACTION

## Page 409
# THE INPUT CODES ASSUMED FOR THE KEYBOARD ARE,
# 0        10000
# 1        00001
# 9        01001
# VERB     10001
# ERROR RES10010
# KEY RLSE 11001
# +        11010
# -        11011
# ENTER    11100
# CLEAR    11110
# NOUN     11111
## 2003 RSB &mdash; The PROCEED key has no keycode; it is read by an alternate mechanism.


# OUTPUT FORMAT FOR DISPLAY PANEL. SET OUT0 TO  AAAABCCCCCDDDDD.
# A-S SELECT A RELAYWORD. THIS DETERMINES WHICH PAIR OF CHARACTERS ARE
# ENERGIZED.
# B FOR SPECIAL RELAYS SUCH AS SIGNS ETC.
# C-S  5 BIT RELAY CODE FOR LEFT CHAR OF PAIR SELECTED BY RELAYWORD
# D-S  5 BIT RELAY CODE FOR RIGHTCHAR OF PAIR SELECTED BY RELAYWORD.

# THE PANEL APPEARS AS FOLLOWS,
# MD1    MD2                         (MAJOR MODE)
# VD1    VD2 (VERB)    ND1    ND2    (NOUN)
# R1D1   R1D2   R1D3   R1D4   R1D5   (R1)
# R2D1   R2D2   R2D3   R2D4   R2D5   (R2)
# R3D1   R3D2   R3D3   R3D4   R3D5   (R3)

# EACH OF THESE IS GIVEN A DSPCOUNT NUMBER FOR USE WITHIN COMPUTATION ONLY
# MD1   25     R2D1  11         ALL ARE OCTAL
# MD2   24     R2D2  10
# VD1   23     R2D3   7
# VD2   22     R2D4   6
# ND1   21     R2D5   5
# ND2   20     R3D1   4
# R1D1  16     R3D2   3
# R1D2  15     R3D3   2
# R1D3  14     R3D4   1
# R1D4  13     R3D5   0
# R1D5  12


# THERE IS AN 11 REGISTER TABLE (DSPTAB) FOR THE DISPLAY PANEL.

# DSPTAB RELAYWD       BIT11     BITS 10-6     BITS 5-1
# RELADD
# 10     1011                    MD1  (25)     MD2  (24)
# 9      1010                    VD1  (23)     VD2  (22)
# 8      1001                    ND1  (21)     ND2  (20)
# 7      1000                                  R1D1 (16)
## Page 410
# 6      0111          +R1       R1D2 (15)     R1D3 (14)
# 5      0110          -R1       R1D4 (13)     R1D5 (12)
# 4      0101          +R2       R2D1 (11)     R2D2 (10)
# 3      0100          -R2       R2D3 (7)      R2D4 (6)
# 2      0011                    R2D5 (5)      R3D1 (4)
# 1      0010          +R3       R3D2 (3)      R3D3 (2)
# 0      0001          -R3       R3D4 (1)      R3D5 (0)
#        0000   NO RELAYWORD


# THE 5 BIT OUTPUT RELAY CODES ARE:
# BLANK      00000
# 0          10101
# 1          00011
# 2          11001
# 3          11011
# 4          01111
# 5          11110
# 6          11100
# 7          10011
# 8          11101
# 9          11111


# OUTPUT BITS USED BY PINBALL:

#            KEY RELEASE LIGHT    - BIT 5 OF CHANNEL 11
#            VERB/NOUN FLASH      - BIT 6 OF CHANNEL 11
#            OPERATOR ERROR LIGHT - BIT 7 OF CHANNEL 11

## <b>Hint:</b> In the source code below, each of the blue operands to the 
## right of the instruction opcodes is a hyperlink back to the definition
## of the symbol.  This is particularly useful for tracing program flow.

## Page 411
# START OF EXECUTIVE SECTION OF PINBALL

                BANK    40
                SETLOC  PINBALL1
                BANK
                
                COUNT*  $$/PIN
CHARIN          CAF     ONE             # BLOCK DISPLAY SYST
                XCH     DSPLOCK         # MAKE DSP SYST BUSY, BUT SAVE OLD
                TS      21/22REG        # C(DSPLOCK) FOR ERROR LIGHT RESET.
                CCS     CADRSTOR        # ALL KEYS EXCEPT ER TURN ON KR LITE IF
                TC      +2              # CADRSTOR IS FULL.  THIS REMINDS OPERATOR
                TC      CHARIN2         # TO RE-ESTABLISH A FLASHING DISPLAY
                CS      ELRCODE1        # WHICH HE HAS OBSCURED WITH DISPLAYS OF
                AD      MPAC            # HIS OWN (SEE REMARKS PRECEDING ROUTINE
                EXTEND                  # VBRELDSP).
                BZF     CHARIN2
                TC      RELDSPON
CHARIN2         XCH     MPAC
                TS      CHAR
                INDEX   A
                TC      +1              # INPUT CODE     FUNCTION
                TC      CHARALRM        # 0
                TC      NUM             # 1
                TC      NUM             # 2
                TC      NUM             # 3
                TC      NUM             # 4
                TC      NUM             # 5
                TC      NUM             # 6
                TC      NUM             # 7
                TC      89TEST          # 10                 8
                TC      89TEST          # 11                 9
                TC      CHARALRM        # 12
                TC      CHARALRM        # 13
                TC      CHARALRM        # 14
                TC      CHARALRM        # 15
                TC      CHARALRM        # 16
                TC      CHARALRM        # 17
                TC      NUM     -2      # 20                 0
                TC      VERB            # 21                 VERB
                TC      ERROR           # 22                 ERROR LIGHT RESET
                TC      CHARALRM        # 23
                TC      CHARALRM        # 24
                TC      CHARALRM        # 25
                TC      CHARALRM        # 26
                TC      CHARALRM        # 27
                TC      CHARALRM        # 30
                TC      VBRELDSP        # 31                 KEY RELEASE
                TC      POSGN           # 32                 +
## Page 412
                TC      NEGSGN          # 33                 -
                TC      ENTERJMP        # 34                 ENTER
                TC      CHARALRM        # 35
                TC      CLEAR           # 36                 CLEAR
                TC      NOUN            # 37                 NOUN
                

ELRCODE1        OCT     22
ENTERJMP        TC      POSTJUMP
                CADR    ENTER
                
89TEST          CCS     DSPCOUNT
                TC      +4              # +
                TC      +3              # +0
                TC      ENDOFJOB        # - BLOCK DATA IN IF DSPCOUNT IS - OR -0
                TC      ENDOFJOB        # -0
                CAF     THREE
                MASK    DECBRNCH
                CCS     A
                TC      NUM             # IF DECBRNCH IS +, 8 OR 9 OK
                TC      CHARALRM        # IF DECBRNCH IS +0, REJECT 8 OR 9
                

# NUM ASSEMBLES OCTAL 3 BITS AT A TIME. FOR DECIMAL IT CONVERTS INCOMING
# WORD AS A FRACTION, KEEPING RESULTS TO DP.
# OCTAL RESULTS ARE LEFT IN XREG, YREG, OR ZREG. HI PART OF DEC IN XREG,
# YREG, ZREG. THE LOW PARTS IN XREGLP, YREGLP, OR ZREGLP)
# DECBRNCH IS LEFT AT +0 FOR OCT, +1 FOR + DEC, +2 FOR - DEC.
# IF DSPCOUNT WAS LEFT -, NO MORE DATA IS ACCEPTED.

                CAF     ZERO
                TS      CHAR
NUM             CCS     DSPCOUNT
                TC      +4              # +
                TC      +3              # +0
                TC      +1              # -BLOCK DATA IN IF DSPCOUNT IS -
                TC      ENDOFJOB        # -0
                TC      GETINREL
                CCS     CLPASS          # IF CLPASS IS + OR +0, MAKE IT +0.
                CAF     ZERO
                TS      CLPASS
                TC      +1
                INDEX   CHAR
                CAF     RELTAB
                MASK    LOW5
                TS      CODE
                CA      DSPCOUNT
                TS      COUNT
                TC      DSPIN
                CAF     THREE
## Page 413
                MASK    DECBRNCH
                CCS     A               # +0, OCTAL.  +1, + DEC.  +2, - DEC.
                TC      DECTOBIN        # +
                INDEX   INREL           # +0 OCTAL
                XCH     VERBREG
                TS      CYL
                CS      CYL
                CS      CYL
                XCH     CYL
                AD      CHAR
                TC      ENDNMTST
DECTOBIN        INDEX   INREL
                XCH     VERBREG
                TS      MPAC            # SUM X 2EXP-14 IN MPAC
                CAF     ZERO
                TS      MPAC +1
                CAF     TEN             # 10 X 2EXP-14
                TC      SHORTMP         # 10SUM X 2EXP-28 IN MPAC, MPAC+1
                XCH     MPAC +1
                AD      CHAR
                TS      MPAC +1
                TC      ENDNMTST        # NO OF
                ADS     MPAC            # OF MUST BE 5TH CHAR
                TC      DECEND
ENDNMTST        INDEX   INREL
                TS      VERBREG
                CS      DSPCOUNT
                INDEX   INREL
                AD      CRITCON
                EXTEND
                BZF     ENDNUM          # -0, DSPCOUNT = CRITCON
                TC      MORNUM          # - , DSPCOUNT G/ CRITCON
ENDNUM          CAF     THREE
                MASK    DECBRNCH
                CCS     A
                TC      DECEND
ENDALL          CS      DSPCOUNT        # BLOCK NUMIN BY PLACING DSPCOUNT
                TC      MORNUM +1       # NEGATIVELY
DECEND          CS      ONE
                AD      INREL
                EXTEND
                BZMF    ENDALL          # IF INREL=0,1(VBREG,NNREG), LEAVE WHOLE
                TC      DMP             # IF INREL=2,3,4(R1,R2,R3),CONVERT TO FRAC
                                        # MULT SUM X 2EXP-28 IN MPAC, MPAC+1 BY
                ADRES   DECON           # 2EXP14/10EXP5. GIVES(SUM/10EXP5)X2EXP-14
                CAF     THREE           # IN MPAC, +1, +2.
                MASK    DECBRNCH
                INDEX   A
                TC      +0
                TC      +DECSGN
## Page 414
                EXTEND                  # - CASE
                DCS     MPAC +1
                DXCH    MPAC +1
+DECSGN         XCH     MPAC +2
                INDEX   INREL
                TS      XREGLP -2
                XCH     MPAC +1
                INDEX   INREL
                TS      VERBREG
                TC      ENDALL
MORNUM          CCS     DSPCOUNT        # DECREMENT DSPCOUNT
                TS      DSPCOUNT
                TC      ENDOFJOB
                
CRITCON         OCT     22              # (DEC 18)
                OCT     20              # (DEC 16)
                OCT     12              # (DEC 10)
                OCT     5
                OCT     0
                
DECON           2DEC    1 E-5 B14       # 2EXP14/10EXP5 = .16384 DEC


# GETINREL GETS PROPER DATA REG REL ADDRESS FOR CURRENT C(DSPCOUNT) AND
# PUTS IN INTO INREL. +0 VERBREG, 1 NOUNREG, 2 XREG, 3 YREG, 4 ZREG.

GETINREL        INDEX   DSPCOUNT
                CAF     INRELTAB
                TS      INREL           # (A TEMP, REG)
                TC      Q
                
INRELTAB        OCT     4               # R3D5 (DSPCOUNT = 0)
                OCT     4               # R3D4           =(1)
                OCT     4               # R3D3           =(2)
                OCT     4               # R3D2           =(3)
                OCT     4               # R3D1           =(4)
                OCT     3               # R2D5           =(5)
                OCT     3               # R2D4           =(6)
                OCT     3               # R2D3           =(7)
                OCT     3               # R2D2           =(8D)
                OCT     3               # R2D1           =(9D)
                OCT     2               # R1D5           =(10D)
                OCT     2               # R1D4           =(11D)
                OCT     2               # R1D3           =(12D)
                OCT     2               # R1D2           =(13D)
                OCT     2               # R1D1           =(14D)
                TC      CCSHOLE         # NO DSPCOUNT NUMBER = 15D
                OCT     1               # ND2            =(16D)
                OCT     1               # ND1            =(17D)
## Page 415
                OCT     0               # VD2            =(18D)
                OCT     0               # VD1            =(19D)
                
VERB            CAF     ZERO
                TS      VERBREG
                CAF     VD1
NVCOM           TS      DSPCOUNT
                TC      2BLANK
                CAF     ONE
                TS      DECBRNCH        # SET FOR DEC V/N CODE
                CAF     ZERO
                TS      REQRET          # SET FOR ENTPAS0
                CAF     ENDINST         # IF DSPALARM OCCURS BEFORE FIRST ENTPAS0
                TS      ENTRET          # OR NVSUB, ENTRET MUST ALREADY BE SET
                                        # TO TC ENDOFJOB
                TC      ENDOFJOB
NOUN            CAF     ZERO
                TS      NOUNREG
                CAF     ND1             # ND1, OCT 21 (DEC 17)
                TC      NVCOM

                
NEGSGN          TC      SIGNTEST
                TC      -ON
                CAF     TWO
BOTHSGN         INDEX   INREL           # SET DEC COMP BIT TO 1 (IN DECBRNCH)
                AD      BIT7            # BIT 5 FOR R1,  BIT 4 FOR R2,
                ADS     DECBRNCH        # BIT 3 FOR R3.
FIXCLPAS        CCS     CLPASS          # IF CLPASS IS + OR +0, MAKE IT +0.
                CAF     ZERO
                TS      CLPASS
                TC      +1
                TC      ENDOFJOB
                
POSGN           TC      SIGNTEST
                TC      +ON
                CAF     ONE
                TC      BOTHSGN
                
+ON             LXCH    Q
                TC      GETINREL
                INDEX   INREL
                CAF     SGNTAB -2
                TS      SGNOFF
                AD      ONE
                TS      SGNON
SGNCOM          CAF     ZERO
                TS      CODE
                XCH     SGNOFF
## Page 416
                TC      11DSPIN
                CAF     BIT11
                TS      CODE
                XCH     SGNON
                TC      11DSPIN
                TC      L
-ON             LXCH    Q
                TC      GETINREL
                INDEX   INREL
                CAF     SGNTAB -2
                TS      SGNON
                AD      ONE
                TS      SGNOFF
                TC      SGNCOM
                
SGNTAB          OCT     5               # -R1
                OCT     3               # -R2
                OCT     0               # -R3

                
SIGNTEST        LXCH    Q               # ALLOWS +,- ONLY WHEN DSPCOUNT=R1D1,
                CAF     THREE           # R2D1, OR R3D1. ALLOWS ONLY FIRST OF
                MASK    DECBRNCH        # CONSECUTIVE +/- CHARACTERS.
                CCS     A               # IF LOW2 BITS OF DECBRNCH NOT= 0, SIGN
                TC      ENDOFJOB        # FOR THIS WORD ALREADY IN. REJECT.
                CS      R1D1
                TC      SGNTST1
                CS      R2D1
                TC      SGNTST1
                CS      R3D1
                TC      SGNTST1
                TC      ENDOFJOB        # NO MATCH FOUND. SIGN ILLEGAL
SGNTST1         AD      DSPCOUNT
                EXTEND
                BZF     +2              # MATCH FOUND
                TC      Q
                TC      L               # SIGN LEGAL

                
# CLEAR BLANKS WHICH R1, R2, R3 IS CURRENT OR LAST TO BE DISPLAYED(PERTINE
# NT XREG,YREG,ZREG IS CLEARED). SUCCESSIVE CLEARS TAKE CARE OF EACH RX
# L/ RC UNTIL R1 IS DONE. THEN NO FURTHER ACTION

# THE SINGLE COMPONENT LOAD VERBS ALLOW ONLY THE SINGLE RC THAT IS 
# APPROPRIATE TO BE CLEARED.

# CLPASS   +0  PASS0, CAN BE BACKED UP
#          +NZ  HIPASS, CAN BE BACKED UP
#          -NZ  PASS0, CANNOT BE BACKED UP

## Page 417
CLEAR           CCS     DSPCOUNT
                AD      ONE
                TC      +2
                AD      ONE
                INDEX   A               # DO NOT CHANGE DSPCOUNT BECAUSE MAY LATER
                CAF     INRELTAB        # FAIL LEGALTST.
                TS      INREL           # MUST SET INREL, EVEN FOR HIPASS.
                CCS     CLPASS
                TC      CLPASHI         # +
                TC      +2              # +0    IF CLPASS IS +0 OR -, IT IS PASS0
                TC      +1              # -
                CA      INREL
                TC      LEGALTST
                TC      CLEAR1
CLPASHI         CCS     INREL
                TS      INREL
                TC      LEGALTST
                CAF     DOUBLK +2       # +3 TO - NUMBER. BACKS DATA REQUESTS.
                ADS     REQRET
                CA      INREL
                TS      MIXTEMP         # TEMP STORAGE FOR INREL
                EXTEND
                DIM     VERBREG         # DECREMENT VERB AND RE-DISPLAY
                TC      BANKCALL
                CADR    UPDATVB
                CA      MIXTEMP
                TS      INREL           # RESTORE INREL
CLEAR1          TC      CLR5
                INCR    CLPASS          # ONLY IF CLPASS IS + OR +0,
                TC      ENDOFJOB        # SET FOR HIGHER PASS.
CLR5            LXCH    Q               # USES 5BLANK  BUT AVOIDS ITS TC GETINREL
                TC      5BLANK +2
LEGALTST        AD      NEG2
                CCS     A
                TC      Q               # LEGAL  INREL G/ 2
                TC      CCSHOLE
                TC      ENDOFJOB        # ILLEGAL   INREL= 0,1
                TC      Q               # LEGAL    INREL = 2

                
# 5BLANK BLANKS 5 CHAR DISPLAY WORD IN R1, R2, OR R3. IT ALSO ZEROES XREG,
# YREG, OR ZREG.PLACE ANY + DSPCOUNT NUMBER FOR PERTINENT RC INTO DSPCOUNT
# DSPCOUNT IS LEFT SET TO LEFT MOST DSP NUMB FOR RC JUST BLANKED.

                TS      DSPCOUNT        # NEEDED FOR BLANKSUB
5BLANK          LXCH    Q
                TC      GETINREL
                CAF     ZERO
                INDEX   INREL
                TS      VERBREG         # ZERO X, Y, Z REG.
## Page 418
                INDEX   INREL
                TS      XREGLP  -2
                TS      CODE
                INDEX   INREL           # ZERO PERTINENT DEC COMP BIT.
                CS      BIT7            # PROTECT OTHERS
                MASK    DECBRNCH
                MASK    BRNCHCON        # ZERO LOW 2 BITS.
                TS      DECBRNCH
                INDEX   INREL
                CAF     SINBLANK -2     # BLANK ISOLATED CHAR SEPARATELY
                TS      COUNT
                TC      DSPIN
5BLANK1         INDEX   INREL
                CAF     DOUBLK -2
                TS      DSPCOUNT
                TC      2BLANK
                CS      TWO
                ADS     DSPCOUNT
                TC      2BLANK
                INDEX   INREL
                CAF     R1D1 -2
                TS      DSPCOUNT        # SET DSPCOUNT TO LEFT MOST DSP NUMBER
                TC      L               # OF REG. JUST BLANKED
                
SINBLANK        OCT     16              # DEC 14
                OCT     5
                OCT     4
DOUBLK          OCT     15              # DEC 13
                OCT     11              # DEC 9
                OCT     3
                
BRNCHCON        OCT     77774

# 2BLANK BLANKS TWO CHAR. PLACE DSP NUMBER OF LEFT CHAR  OF THE PAIR INTO
# DSPCOUNT. THIS NUMBER IS LEFT IN DSPCOUNT

2BLANK          CA      DSPCOUNT
                TS      SR
                CS      BLANKCON
                INHINT
                INDEX   SR
                XCH     DSPTAB
                EXTEND
                BZMF    +2              # IF OLD CONTENTS -, NOUT OK
                INCR    NOUT            # IF OLD CONTENTS +, +1 TO NOUT
                RELINT                  # IF -,NOUT OK
                TC      Q
BLANKCON        OCT     4000

## Page 419
# ENTER PASS 0 IS THE EXECUTE FUNCTION. HIGHER ORDER ENTERS ARE TO LOAD
# DATA. THE SIGN OF REQRET DETERMINES THE PASS, + FOR PASS 0,- FOR HIGHER
# PASSES.


# MACHINE CADR TO BE SPECIFIED (MCTBS) NOUNS DESIRE AN ECADR TO BE LOADED
# WHEN USED WITH LOAD VERBS, MONITOR VERBS, OR DISPLAY VERBS (EXCEPT
# VERB = FIXED MEMORY DISPLAY, WHICH REQUIRES AN FCADR).


                BANK    41
                SETLOC  PINBALL2
                BANK
                
                COUNT*  $$/PIN
NVSUBB          TC      NVSUB1          # STANDARD LEAD INS. DONT MOVE.
LOADLV1         TC      LOADLV
                                        # END OF STANDARD LEAD INS.


ENTER           CAF     ZERO
                TS      CLPASS
                CAF     ENDINST
                TS      ENTRET
                CCS     REQRET
                TC      ENTPAS0         # IF +, PASS 0
                TC      ENTPAS0         # IF +, PASS 0
                TC      +1              # IF -, NOT PASS 0
ENTPASHI        CAF     MMADREF
                AD      REQRET          # IF L/ 2 CHAR IN FOR MM CODE, ALARM
                EXTEND                  # AND RECYCLE(DECIDE AT MMCHANG+1).
                BZF     ACCEPTWD
                CAF     THREE           # IF DEC, ALARM IF L/ 5 CHAR IN FOR DATA,
                MASK    DECBRNCH        # BUT LEAVE REQRET - AND FLASH ON, SO
                CCS     A               # OPERATOR CAN SUPPLY MISSING NUMERICAL
                TC      +2              # CHARACTERS AND CONTINUE.
                TC      ACCEPTWD        # OCTAL. ANY NUMBER OF CHAR OK.
                CCS     DSPCOUNT
                TC      GODSPALM        # LESS THAN 5 CHAR DEC(DSPCOUNT IS +)
                TC      GODSPALM        # LESS THAN 5 CHAR DEC(DSPCOUNT IS +)
                TC      +1              # 5 CHAR IN (DSPCOUNT IS -)
ACCEPTWD        CS      REQRET          # 5 CHAR IN (DSPCOUNT IS -)
                TS      REQRET          # SET REQRET +.
                TC      FLASHOFF
                TC      REQRET
                
ENTEXIT         =       ENTRET

MMADREF         ADRES   MMCHANG +1      # ASSUMES TC REQMM AT MMCHANG.

## Page 420
LOWVERB         DEC     28              # LOWER VERB THAT AVOIDS NOUN TEST.

ENTPAS0         CAF     ZERO            #  NOUN VERB SUB ENTERS HERE
                TS      DECBRNCH
                CS      VD1             # BLOCK FURTHER NUM CHAR, SO THAT STRAY
                TS      DSPCOUNT        # CHAR DO NOT GET INTO VERB OR NOUN LTS.
TESTVB          CS      VERBREG         # IF VERB IS G/E LOWVB, SKIP NOUN TEST.
                TS      VERBSAVE        # SAVE VERB FOR POSSIBLE RECYCLE.
                AD      LOWVERB         # LOWVERB - VB
                EXTEND
                BZMF    VERBFAN         # VERB G/E LOWVERB
TESTNN          EXTEND                  # VERB L/ LOWVERB
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                INDEX   MIXBR
                TC      +0
                TC      +2              # NORMAL
                TC      MIXNOUN         # MIXED
                CCS     NNADTEM         # NORMAL
                TC      VERBFAN -2      #      NORMAL IF +
                TC      GODSPALM        # NOT IN USE   IF +0
                TC      REQADD          # SPECIFY MACHINE CADR IF -
                INCR    NOUNCADR        # AUGMENT MACHINE CADR IF -0
                TC      SETNADD         # ECADR FROM NOUNCADR. SETS EB, NOUNADD.
                TC      INTMCTBS +2
REQADD          CAF     BIT15           # SET CLPASS FOR PASS0 ONLY
                TS      CLPASS
                CS      ENDINST         # TEST IF REACHED HERE FROM INTERNAL OR
                AD      ENTEXIT         #             FROM EXTERNAL
                EXTEND
                BZF     +2              # EXTERNAL MACH CADR TO BE SPECIFIED
                TC      INTMCTBS
                TC      REQDATZ         # EXTERNAL MACH CADR TO BE SPECIFIED
                CCS     DECBRNCH        # ALARM AND RECYCLE IF DECIMAL USED
                TC      ALMCYCLE        # FOR MCTBS.
                CS      VD1             # OCTAL USED  OK
                TS      DSPCOUNT        # BLOCK NUM CHAR IN
                CCS     CADRSTOR
                TC      +3              # EXTERNAL MCTBS DISPLAY WILL LEAVE FLASH
                TC      USEADD          # ON IF ENDIDLE NOT = +0.
                TC      +1
                TC      FLASHON
USEADD          XCH     ZREG
                TC      SETNCADR        # ECADR INTO NOUNCADR. SET EB, NOUNADD.
                EXTEND
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                TC      VERBFAN
                
                EBANK=  DSPCOUNT
## Page 421
LODNNLOC        2CADR   LODNNTAB


NEG5            OCT     77772

INTMCTBS        CA      MPAC    +2      # INTERNAL MACH CADR TO BE SPECIFIED.
                TC      SETNCADR        # ECADR INTO NOUNCADR. SET EB, NOUNADD.
                CS      FIVE            # NVSUB CALL LEFT CADR IN MPAC+2 FOR MACH
                AD      VERBREG         # CADR TO BE SPECIFIED.
                EXTEND
                BZF     VERBFAN         # DONT DISPLAY CADR IF VB = 05.
                CAF     R3D1            # VB NOT = 05. DISPLAY CADR.
                TS      DSPCOUNT
                CA      NOUNCADR
                TC      DSPOCTWO
                TC      VERBFAN
                
                AD      ONE
                TC      SETNCADR        # ECADR INTO NOUNCADR. SETS EB, NOUNADD.
VERBFAN         CS      LST2CON
                AD      VERBREG         # VERB-LST2CON
                CCS     A
                AD      ONE             # VERB G/ LST2CON
                TC      +2
                TC      VBFANDIR        # VERB L/ LST2CON
                TS      MPAC
                TC      RELDSP          # RELEASE DISPLAY SYST
                TC      POSTJUMP        # GO TO GOEXTVB WITH VB-40 IN MPAC.
                CADR    GOEXTVB
LST2CON         DEC     40              # FIRST LIST2 VERB (EXTENDED VERB)

VBFANDIR        INDEX   VERBREG
                CAF     VERBTAB
                TC      BANKJUMP
                
VERBTAB         CADR    GODSPALM        # VB00 ILLEGAL
                CADR    DSPA            # VB01 DISPLAY OCT COMP 1 (R1)
                CADR    DSPB            # VB02 DISPLAY OCT COMP 2 (R1)
                CADR    DSPC            # VB03 DISPLAY OCT COMP 3 (R1)
                CADR    DSPAB           # VB04 DISPLAY OCT COMP 1,2 (R1,R2)
                CADR    DSPABC          # VB05 DISPLAY OCT COMP 1,2,3 (R1,R2,R3)
                CADR    DECDSP          # VB06 DECIMAL DISPLAY
                CADR    DSPDPDEC        # VB07 DP DECIMAL DISPLAY (R1,R2)
                CADR    GODSPALM        # VB08 SPARE
                CADR    GODSPALM        # VB09 SPARE
                CADR    DSPALARM        # VB10 SPARE
                CADR    MONITOR         # VB11 MONITOR OCT COMP 1 (R1)
                CADR    MONITOR         # VB12 MONITOR OCT COMP 2 (R1)
                CADR    MONITOR         # VB13 MONITOR OCT COMP 3 (R1)
                CADR    MONITOR         # VB14 MONITOR OCT COMP 1,2 (R1,R2)
## Page 422
                CADR    MONITOR         # VB15 MONITOR OCT COMP 1,2,3 (R1,R2,R3)
                CADR    MONITOR         # VB16 MONITOR DECIMAL
                CADR    MONITOR         # VB17 MONITOR DP DEC  (R1,R2)
                CADR    GODSPALM        # VB18 SPARE
                CADR    GODSPALM        # VB19 SPARE
                CADR    GODSPALM        # VB20 SPARE
                CADR    ALOAD           # VB21 LOAD COMP 1 (R1)
                CADR    BLOAD           # VB22 LOAD COMP 2 (R2)
                CADR    CLOAD           # VB23 LOAD COMP 3 (R3)
                CADR    ABLOAD          # VB24 LOAD COMP 1,2 (R1,R2)
                CADR    ABCLOAD         # VB25 LOAD COMP 1,2,3 (R1,R2,R3)
                CADR    GODSPALM        # VB26 SPARE
                CADR    DSPFMEM         # VB27 FIXED MEMORY DISPLAY
                                        # THE FOLLOWING VERBS MAKE NO NOUN TEST
                CADR    GODSPALM        # VB28 SPARE
                CADR    GODSPALM        # VB29 SPARE
REQEXLOC        CADR    VBRQEXEC        # VB30 REQUEST EXECUTIVE
                CADR    VBRQWAIT        # VB31 REQUEST WAITLIST
                CADR    VBRESEQ         # VB32 RESEQUENCE
                CADR    VBPROC          # VB33 PROCEED WITHOUT DATA
                CADR    VBTERM          # VB34 TERMINATE CURRENT TEST OR LOAD REQ
                CADR    VBTSTLTS        # VB35 TEST LIGHTS
                CADR    SLAP1           # VB36 FRESH START
                CADR    MMCHANG         # VB37 CHANGE MAJOR MODE
                CADR    GODSPALM        # VB38 SPARE
                CADR    GODSPALM        # VB39 SPARE
                

# THE LIST2 VERBFAN IS LOCATED IN THE EXTENDED VERB BANK.

## Page 423
# NNADTAB CONTAINS A RELATIVE ADDRESS, IDADDREL(IN LOW 10 BITS), REFERRING
# TO WHERE 3 CONSECUTIVE ADDRESSES ARE STORED (IN IDADDTAB).
# MIXNOUN GETS DATA AND STORES IN MIXTEMP,+1,+2. IT SETS NOUNADD FOR
#  MIXTEMP.

MIXNOUN         CCS     NNADTEM
                TC      +4              # +  IN USE
                TC      GODSPALM        # +0  NOT IN USE
                TC      +2              # -  IN USE
                TC      +1              # -0  IN USE
                CS      SIX
                AD      VERBREG
                EXTEND
                BZMF    +2              # VERB L/E 6
                TC      VERBFAN         # AVOID MIXNOUN SWAP IF VB NOT = DISPLAY
                CAF     TWO
MIXNN1          TS      DECOUNT
                AD      MIXAD
                TS      NOUNADD         # SET NOUNADD TO MIXTEMP + K
                INDEX   DECOUNT         # GET IDADDTAB ENTRY FOR COMPONENT K
                CA      IDAD1TEM        # OF NOUN.
                TS      NOUNTEM
                                        # TEST FOR DP(FOR OCT DISPLAY). IF SO, GET
                                        #   MINOR PART ONLY.
                TC      SFRUTMIX        # GET SF ROUT NUMBER IN A
                TC      DPTEST
                TC      MIXNN2          # NO DP
                INCR    NOUNTEM         # DP GET MINOR PART
MIXNN2          CA      NOUNTEM
                MASK    LOW11           # ESUBK (NO DP) OR (ESUBK)+1     FOR DP
                TC      SETEBANK        # SET EBANK, LEAVE EADRES IN A.
                INDEX   A               # PICK UP C(ESUBK)  NOT DP
                CA      0               # OR C((ESUBK)+1)  FOR DP MINOR PART
                INDEX   NOUNADD
                XCH     0               # STORE IN MIXTEM + K
                CCS     DECOUNT
                TC      MIXNN1
                TC      VERBFAN
        
MIXAD           TC      MIXTEMP


# DPTEST   ENTER WITH SF ROUT NUMBER IN A.
#          RETURNS TO L+1 IF NO DP.
#          RETURNS TO L+2 IF DP.

DPTEST          INDEX   A
                TCF     +1
                TC      Q               # OCTAL ONLY  NO DP
                TC      Q               # FRACT NO DP
## Page 424
                TC      Q               # DEG  NO DP
                TC      Q               # ARITH  NO DP
                TCF     DPTEST1         # DP1OUT
                TCF     DPTEST1         # DP2OUT
                TC      Q               # LRPOSOUT NO DP (DATA IN CHANNEL 33)
                TCF     DPTEST1         # DP3OUT
                TC      Q               # HMS   NO DP
                TC      Q               # M/S   NO DP
                TCF     DPTEST1         # DP4OUT
                TC      Q               # ARITH1   NO DP
                TC      Q               # 2INTOUT  NO DP TO GET HI PART IN MPAC
                TC      Q               # 360-CDU   NO DP
DPTEST1         INDEX   Q
                TC      1               # RETURN TO L+2

                
REQDATX         CAF     R1D1
                TCF     REQCOM
REQDATY         CAF     R2D1
                TCF     REQCOM
REQDATZ         CAF     R3D1
REQCOM          TS      DSPCOUNT
                CS      Q
                TS      REQRET
                TC      BANKCALL
                CADR    5BLANK
                TC      FLASHON
ENDRQDAT        TC      ENTEXIT

                TS      NOUNREG
UPDATNN         XCH     Q
                TS      UPDATRET
                EXTEND
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                CCS     NNADTEM
                AD      ONE             # NORMAL
                TCF     PUTADD
                TCF     PUTADD +1       # MCTBS  DONT CHANGE NOUNADD
                TCF     PUTADD +1       # MCTBI  DONT CHANGE NOUNADD
PUTADD          TC      SETNCADR        # ECADR INTO NOUNCADR. SETS EB, NOUNADD.
                CAF     ND1
                TS      DSPCOUNT
                CA      NOUNREG
                TCF     UPDAT1
                
                TS      VERBREG
UPDATVB         XCH     Q
                TS      UPDATRET
                CAF     VD1
## Page 425
                TS      DSPCOUNT
                CA      VERBREG
UPDAT1          TC      POSTJUMP        # CANT USE SWCALL TO GO TO DSPDECVN,SINCE
                CADR    GOVNUPDT        # UPDATVB CAN ITSELF BE CALLED BY SWCALL.
                TC      UPDATRET
                

GOALMCYC        TC      ALMCYCLE        # NEEDED BECAUSE BANKJUMP CANT HANDLE F/F.


GODSPALM        TC      POSTJUMP
                CADR    DSPALARM
                
## Page 426
#          NOUN   TABLES
# NOUN CODE L/40, NORMAL NOUN CASE.  NOUN CODE G/E 40, MIXED NOUN CASE.
# FOR NORMAL CASE, NNADTAB CONTAINS ONE       ECADR     FOR EACH NOUN.
# +0 INDICATES NOUN NOT USED.   - ENTRY INDICATES MACHINE CADR(E OR F) TO
# BE SPECIFIED. -1 INDICATES CHANNEL TO BE SPECIFIED. -0 INDICATES AUGMENT
# OF LAST MACHINE CADR SUPPLIED.

# FOR MIXED CASE, NNADTAB CONTAINS ONE INDIRECT ADDRESS(IDADDREL) IN LOW
# 10 BITS, AND THE COMPONENT CODE NUMBER IN THE HIGH 5 BITS.

# NNTYPTAB IS A PACKED TABLE OF THE FORM MMMMMNNNNNPPPPP.

# FOR THE NORMAL CASE, M-S ARE THE COMPONENT CODE NUMBER.
#                      N-S ARE THE SF ROUTINE CODE NUMBER.
#                      P-S ARE THE SF CONSTANT CODE NUMBER.

# MIXED CASE,M-S ARE THE SF CONSTANT3 CODE NUMBER     3 COMPONENT CASE
#            N-S ARE THE SF CONSTANT2 CODE NUMBER
#            P-S ARE THE SF CONSTANT1 CODE NUMBER
#            N-S ARE THE SF CONSTANT2 CODE NUMBER     2 COMPONENT CASE
#            P-S ARE THE SF CONSTANT1 CODE NUMBER
#            P-S ARE THE SF CONSTANT1 CODE NUMBER      1 COMPONENT CASE

# THERE IS ALSO AN INDIRECT ADDRESS TABLE(IDADDTAB) FOR MIXED CASE ONLY.
# EACH ENTRY CONTAINS ONE ECADR.    IDADDREL IS THE RELATIVE ADDRESS OF
# THE FIRST OF THESE ENTRIES.
# THERE IS ONE ENTRY IN THIS TABLE FOR EACH COMPONENT OF A MIXED NOUN
# THEY ARE LISTED IN ORDER OF ASCENDING K.

# THERE IS ALSO A SCALE FACTOR ROUTINE NUMBER TABLE( RUTMXTAB ) FOR MIXED
# CASE ONLY. THERE IS ONE ENTRY PER MIXED NOUN. THE FORM IS,
#       QQQQQRRRRRSSSSS
# Q-S ARE THE SF ROUTINE 3 CODE NUMBER     3 COMPONENT CASE
# R-S ARE THE SF ROUTINE 2 CODE NUMBER
# S-S ARE THE SF ROUTINE 1 CODE NUMBER
# R-S ARE THE SF ROUTINE 2 CODE NUMBER     2 COMPONENT CASE
# S-S ARE THE SF ROUTINE 1 CODE NUMBER


# IN OCTAL DISPLAY AND LOAD (OCT OR DEC) VERBS, EXCLUDE USE OF VERBS WHOSE
# COMPONENT NUMBER IS GREATER THAN THE NUMBER OF COMPONENTS IN NOUN.
# (ALL MACHINE ADDRESS TO BE SPECIFIED NOUNS ARE 3 COMPONENT.)


# IN MULTI-COMPONENT LOAD VERBS, NO MIXING OF OCTAL AND DECIMAL DATA
# COMPONENT WORDS IS ALLOWED. ALARM IF VIOLATION.

# IN DECIMAL LOADS OF DATA, 5 NUMERICAL CHARACTERS MUST BE KEYED IN
# BEFORE EACH ENTER. IF NOT, ALARM.

## Page 427
#          DISPLAY  VERBS
DSPABC          CS      TWO
                TC      COMPTEST
                INDEX   NOUNADD
                CS      2
                XCH     BUF     +2
DSPAB           CS      ONE
                TC      COMPTEST
                INDEX   NOUNADD
                CS      1
                XCH     BUF     +1
DSPA            TC      DECTEST
                TC      TSTFORDP
                INDEX   NOUNADD
                CS      0
DSPCOM1         XCH     BUF
                TC      DSPCOM2
DSPB            CS      ONE
                TC      DCOMPTST
                INDEX   NOUNADD
                CS      1
                TC      DSPCOM1
DSPC            CS      TWO
                TC      DCOMPTST
                INDEX   NOUNADD
                CS      2
                TC      DSPCOM1
DSPCOM2         CS      TWO             # A  B  C  AB ABC
                AD      VERBREG         # -1 -0 +1 +2 +3    IN A
                CCS     A               # +0 +0 +0 +1 +2     IN A AFTER CCS
                TC      DSPCOM3
                TC      ENTEXIT
                TC      +1
DSPCOM3         TS      DISTEM          # +0,+1,+2 INTO DISTEM
                INDEX   A
                CAF     R1D1
                TS      DSPCOUNT
                INDEX   DISTEM
                CS      BUF
                TC      DSPOCTWO
                XCH     DISTEM
                TC      DSPCOM2 +2
                
# COMPTEST ALARMS IF COMPONENT NUMBER OF VERB(LOAD OR OCT DISPLAY) IS
# GREATER THAN THE HIGHEST COMPONENT NUMBER OF NOUN.
COMPTEST        TS      SFTEMP1         # - VERB COMP
                LXCH    Q
COMPTST1        TC      GETCOMP
                TC      LEFT5
                MASK    THREE           # NOUN COMP
## Page 428
                AD      SFTEMP1         # NOUN COMP - VERB COMP
                CCS     A
                TC      L               # NOUN COMP G/ VERB COMP
                TC      CCSHOLE
                TC      GODSPALM        # NOUN COMP L/ VERB COMP
NDCMPTST        TC      L               # NOUN COMP = VERB COMP


# DCOMPTST ALARMS IF DECIMAL ONLY BIT (BIT4 OF COMP CODE NUMBER) = 1.
# IF NOT, IT PERFORMS REGULAR COMPTEST.
DCOMPTST        TS      SFTEMP1         # - VERB COMP
                LXCH    Q
                TC      DECTEST
                TC      COMPTST1
                
DECTEST         EXTEND                  # ALARMS IF DEC ONLY BIT = 1 (BIT4 OF COMP
                QXCH    MPAC +2         # CODE NUMBER). RETURNS IF NOT.
                TC      GETCOMP
                MASK    BIT14
                CCS     A
                TC      GODSPALM
                TC      MPAC +2


DCTSTCYC        LXCH    Q               # ALARMS AND RECYCLES IF DEC ONLY BIT = 1
                TC      GETCOMP         # ( BIT4 OF COMP CODE NUMBER). RETURNS
                MASK    BIT14           # IF NOT.  USED BY LOAD VERBS.
                CCS     A
                TC      ALMCYCLE
                TC      L

                
# NOUNTEST ALARMS IF NO-LOAD BIT (BIT5 OF COMP CODE NUMBER) = 1.
# IF NOT, IT RETURNS.
NOUNTEST        LXCH    Q
                TC      GETCOMP
                CCS     A
                TC      L
                TC      L
                TC      GODSPALM

                
TSTFORDP        LXCH    Q               # TEST FOR DP. IF SO, GET MINOR PART ONLY.
                CA      NNADTEM
                AD      ONE             # IF NNADTEM = -1, CHANNEL TO BE SPECIFIED
                EXTEND
                BZF     CHANDSP
                INDEX   MIXBR
                TC      +0
                TC      +2              # NORMAL
## Page 429
                TC      L               # MIXED CASE ALREADY HANDLED IN MIXNOUN
                TC      SFRUTNOR
                TC      DPTEST
                TC      L               # NO DP
                INCR    NOUNADD         # DP    E+1 INTO NOUNADD FOR MINOR PART.
                TC      L

                
CHANDSP         CA      NOUNCADR
                MASK    LOW9
                EXTEND
                INDEX   A
                READ    0
                CS      A
                TCF     DSPCOM1
                

COMPICK         ADRES   NNTYPTEM
                ADRES   NNADTEM
                
GETCOMP         INDEX   MIXBR           # NORMAL                MIXED
                CAF     COMPICK -1      # ADRES NNTYPTEM        ADRES NNADTEM
                INDEX   A
                CA      0               # C(NNTYPTEM)           C(NNADTEM)
                MASK    HI5             # GET HI5 OF NNTYPTAB(NORM)OF NNADTAB (MIX)
                TC      Q


DECDSP          TC      GETCOMP
                TC      LEFT5
                MASK    THREE
                TS      DECOUNT         # COMP NUMBER INTO DECOUNT
DSPDCGET        TS      DECTEM          # PICKS UP DATA
                AD      NOUNADD         # DECTEM 1COMP +0, 2COMP +1, 3COMP +2
                INDEX   A
                CS      0
                INDEX   DECTEM
                XCH     XREG            # CANT USE BUF SINCE DMP USES IT.
                CCS     DECTEM
                TC      DSPDCGET        # MORE TO GET
DSPDCPUT        CAF     ZERO            # DISPLAYS DATA
                TS      MPAC +1         # DECOUNT 1COMP +0, 2COMP +1, 3COMP +2
                TS      MPAC +2
                INDEX   DECOUNT
                CAF     R1D1
                TS      DSPCOUNT
                INDEX   DECOUNT
                CS      XREG
                TS      MPAC
                TC      SFCONUM         # 2X ( SF CON NUMB ) IN A
## Page 430
                TS      SFTEMP1
                EXTEND                  # SWITCH BANKS TO SF CONSTANT TABLE
                DCA     GTSFOUTL        #    READING ROUTINE.
                DXCH    Z               # LOADS SFTEMP1, SFTEMP2.
                INDEX   MIXBR
                TC      +0
                TC      DSPSFNOR
                TC      SFRUTMIX
                TC      DECDSP3

DSPSFNOR        TC      SFRUTNOR
                TC      DECDSP3

                EBANK=  DSPCOUNT
GTSFOUTL        2CADR   GTSFOUT



DSPDCEND        TC      BANKCALL        # ALL SFOUT ROUTINES END HERE
                CADR    DSPDECWD
                CCS     DECOUNT
                TC      +2
                TC      ENTEXIT
                TS      DECOUNT
                TC      DSPDCPUT        # MORE TO DISPLAY

DECDSP3         INDEX   A
                CAF     SFOUTABR
                TC      BANKJUMP

SFOUTABR        CADR    PREDSPAL        # ALARM IF DEC DISP WITH OCTAL ONLY NOUN
                CADR    DSPDCEND
                CADR    DEGOUTSF
                CADR    ARTOUTSF
                CADR    DP1OUTSF
                CADR    DP2OUTSF
                CADR    LRPOSOUT
                CADR    DP3OUTSF
                CADR    HMSOUT
                CADR    M/SOUT
                CADR    DP2OUTSF
                CADR    AROUT1SF
                CADR    2INTOUT
                CADR    360-CDUO
ENDRTOUT        EQUALS


#         THE FOLLOWING IS ATYPICAL SF ROUTINE . IT USES MPAC. LEAVES RESU
# LTS IN MPAC, MPAC+1. ENDS WITH TC DSPDCEND

## Page 431
                SETLOC  BLANKCON +1
                
                COUNT*  $$/PIN
#    DEGOUTSF SCALES BY .18 THE LOW 14 BITS OF ANGLE , ADDING .18 FOR
# NUMBERS IN THE NEGATIVE (AGC) RANGE.

DEGOUTSF        CAF     ZERO
                TS      MPAC +2         # SET INDEX FOR FULL SCALE
                TC      FIXRANGE
                TC      +2              # NO AUGMENT NEEDED (SFTEMP1 AND 2 ARE 0)
                TC      SETAUG          # SET AUGMENTER ACCORDING TO C(MPAC +2)
                TC      DEGCOM
                
# 360-CDUD COMPUTES 360 - CDU ANGLE IN MPAC, STORES RESULT IN MPAC AND
# GOES TO DEGOUTSF.

360-CDUO        TC      360-CDU
                TC      DEGOUTSF
                
360-CDU         CA      MPAC
                MASK    POSMAX          # IF ANGLE IS 0 OR 180 DEGREES, DO NOTHING
                EXTEND
                BZF     360-CDUE
                CS      MPAC            # COMPUTE 360 DEGREES MINUS ANGLE
                AD      ONE
                TS      MPAC
360-CDUE        TC      Q

# LRPOSOUT DISPLAYS +0,1,2,OR 3 (WHOLE) FOR CHANNEL 33,BITS 7-6 = 11,10,
# 01,00 RESPECTIVELY.

LRPOSOUT        EXTEND
                READ    CHAN33
                EXTEND
                MP      BIT10           # BITS 7-6 TO BITS 2-1
                COM
                MASK    THREE
                TS      MPAC
                TC      ARTOUTSF        # DISPLAY AS WHOLE
                
SETAUG          EXTEND                  # LOADS SFTEMP1 AND SFTEMP2 WITH THE
                INDEX   MPAC +2         # DP AUGMENTER CONSTANT
                DCA     DEGTAB
                DXCH    SFTEMP1
                TC      Q
                
FIXRANGE        CCS     MPAC            # IF MPAC IS + RETURN TO L+1
                TC      Q               # IF MPAC IS - RETURN TO L+2 AFTER
                TC      Q               # MASKING OUT THE SIGN BIT
                TCF     +1

## Page 432
                CS      BIT15
                MASK    MPAC
                TS      MPAC
                INDEX   Q
                TC      1
                
DEGCOM          EXTEND                  # LOADS MULTIPLIER , DOES SHORTMP, AND
                INDEX   MPAC +2         # ADDS AUGMENTER.
                DCA     DEGTAB
                DXCH    MPAC            # ADJUSTED ANGLE IN A
                TC      SHORTMP
                DXCH    SFTEMP1
                DAS     MPAC
                TC      SCOUTEND

                
DEGTAB          OCT     05605           # HI PART OF     .18
                OCT     03656           # LOW PART OF    .18
                OCT     16314           # HI PART OF     .45
                OCT     31463           # LO PART OF     .45
                
ARTOUTSF        DXCH    SFTEMP1         # ASSUMES POINT AT LEFT OF DP SFCON
                DXCH    MPAC
                TC      PRSHRTMP        # IF C(A) = -0, SHORTMP FAILS TO GIVE -0.
SCOUTEND        TC      POSTJUMP
                CADR    DSPDCEND
                
AROUT1SF        DXCH    SFTEMP1         # ASSUMES POINT BETWEEN HI AND LO PARTS OF
                DXCH    MPAC            # DP SFCON. SHIFTS RESULTS LEFT 14, BY
                TC      PRSHRTMP        # TAKING RESULTS FROM MPAC+1, MPAC+2.
                TC      L14/OUT

                
DP1OUTSF        TC      DPOUT           # SCALES MPAC, MPAC +1 BY DP SCALE FACTOR
L14/OUT         XCH     MPAC +2         # IN SFTEMP1, SFTEMP2. THEN SCALE RESULT
                XCH     MPAC +1         # BY B14.
                TS      MPAC
                TC      SCOUTEND
                

DP2OUTSF        TC      DPOUT           # SCALES MPAC, MPAC +1 BY DP SCALE FACTOR
                TC      SCOUTEND

                
DP3OUTSF        TC      DPOUT           # ASSUMES POINT BETWEEN BITS 7-8 OF HIGH
                CAF     SIX             # LEFT BY 7, ROUNDS MPAC+2 INTO MPAC+1.
                TC      TPLEFTN         # SHIFT LEFT 7.
                TC      SCOUTEND

## Page 433
MPAC+6          =       MPAC +6         # USE MPAC +6 INSTEAD OF OVFIND

DPOUT           XCH     Q
                TS      MPAC+6
                TC      READLO          # GET FRESH DATA FOR BOTH HI AND LO.
                TC      TPAGREE         # MAKE DP DATA AGREE
                TC      DMP
                ADRES   SFTEMP1
                TC      MPAC+6
# THE FOLLOWING ROUTINE DISPLAYS TWO CONTIGUOUS SP POSITIVE INTEGERS
# AS TWO POSITIVE DECIMAL INTEGERS IN RXD1-RXD2 AND RXD4-RXD5 (RXD3 IS
# BLANKED). THE INTEGER IN THE LOWER NUMBERED ADDRESS IS DISPLAYED IN
# RXD1-RXD2.

2INTOUT         TC      5BLANK          # TO BLANK RXD3
                TC      +ON             # TURN ON + SIGN
                CA      MPAC
                TC      DSPDECVN        # DISPLAY 1ST INTEGER (LIKE VERB AND NOUN)
                CS      THREE
                INDEX   DECOUNT
                AD      R1D1            # RXD4
                TS      DSPCOUNT
                TC      READLO          # GET 2ND INTEGER
                CA      MPAC +1
                TC      DSPDECVN        # DISPLAY 2ND INTEGER (LIKE VERB AND NOUN)
                TC      POSTJUMP
                CADR    DSPDCEND +2

                
# READLO PICKS UP FRESH DATA FOR BOTH HI AND LO AND LEAVES IT IN 
# MPAC, MPAC+1. THIS IS NEEDED FOR TIME DISPLAY. IT ZEROES MPAC+2, BUT
# DOES NOT FORCE TPAGREE.

READLO          XCH     Q
                TS      TEM4
                INDEX   MIXBR
                TC      +0
                TC      RDLONOR
                INDEX   DECOUNT
                CA      IDAD1TEM        # GET IDADDTAB ENTRY FOR COMP K OF NOUN.
                MASK    LOW11           # E SUBK
                TC      SETEBANK        # SET EB, LEAVE EADRES IN A.
READLO1         EXTEND                  # MIXED         NORMAL
                INDEX   A               # C(ESUBK)      C(E)
                DCA     0               # C((E SUBK)+1)      C(E+1)
                DXCH    MPAC
                CAF     ZERO
                TS      MPAC    +2
                TC      TEM4
## Page 434
RDLONOR         CA      NOUNADD         # E
ENDRDLO         TC      READLO1


                BANK    42
                SETLOC  PINBALL3
                BANK
                
                COUNT*  $$/PIN
HMSOUT          TC      BANKCALL        # READ FRESH DATA FOR HI AND LO INTO MPAC,
                CADR    READLO          # MPAC+1.
                TC      TPAGREE         # MAKE DP DATA AGREE
                TC      SEPSECNR        # LEAVE FRACT SEC/60 IN MPAC, MPAC+1.LEAVE
                                        # WHOLE MIN IN BIT13 OF LOTEMOUT AND ABOVE
                TC      DMP             # USE ONLY FRACT SEC/60 MOD 60
                ADRES   SECON2          # MULT BY .06
                CAF     R3D1            # GIVES CENTI-SEC/10EXP5 MOD 60
                TS      DSPCOUNT
                TC      BANKCALL        # DISPLAY SEC MOD 60
                CADR    DSPDECWD
                TC      SEPMIN          # REMOVE REST OF SECONDS
                CAF     MINCON2         # LEAVE FRACT MIN/60 IN MPAC+1. LEAVE
                XCH     MPAC            # WHOLE HOURS IN MPAC.
                TS      HITEMOUT        # SAVE WHOLE HOURS.
                CAF     MINCON2 +1
                XCH     MPAC    +1      # USE ONLY FRACT MIN/60 MOD 60
                TC      PRSHRTMP        # IF C(A) = -0, SHORTMP FAILS TO GIVE -0.
                                        # MULT BY .0006
                CAF     R2D1            # GIVES MIN/10EXP5 MOD 60
                TS      DSPCOUNT
                TC      BANKCALL        # DISPLAY MIN MOD 60
                CADR    DSPDECWD
                EXTEND                  # MINUTES, SECONDS HAVE BEEN REMOVED
                DCA     HRCON1
                DXCH    MPAC
                CA      HITEMOUT        # USE WHOLE HOURS
                TC      PRSHRTMP        # IF C(A) = -0, SHORTMP FAILS TO GIVE -0.
                                        # MULT BY .16384
                CAF     R1D1            # GIVES HOURS/10EXP5
                TS      DSPCOUNT
                TC      BANKCALL        # USE REGULAR DSPDECWD, WITH ROUND OFF.
                CADR    DSPDECWD
                TC      ENTEXIT
                
SECON1          2DEC*   1.666666666 E-4 B12* #  2EXP12/6000

SECON2          OCT     01727           # .06 FOR SECONDS DISPLAY
                OCT     01217
MINCON2         OCT     00011           # .0006 FOR MINUTES DISLPAY
                OCT     32445
## Page 435
MINCON1         OCT     02104           # .066..66 UPPED BY 2EXP-28
                OCT     10422
HRCON1          2DEC    .16384 

                OCT     00000 
RNDCON          OCT     00062           # .5 SEC


M/SOUT          TC      BANKCALL        # READ FRESH DATA FOR HI AND LO INTO MPAC,
                CADR    READLO          # MPAC+1.
                TC      TPAGREE         # MAKE DP DATA AGREE
                CCS     MPAC            # IF MAG OF (MPAC, MPAC+1) G/ 59 M 59 S,
                TC      +2              # DISPLAY 59B59, WITH PROPER SIGN.
                TC      M/SNORM         # MPAC = +0. L/ 59M58.5S
                AD      M/SCON1         # - HI PART OF (59M58.5S) +1  FOR CCS
                CCS     A               # MAG OF MPAC - HI PART OF (59M58.5S)
                TC      M/SLIMIT        # G/ 59M58.5S
                TC      M/SNORM         # ORIGINAL MPAC = -0. L/ 59M58.5S
                TC      M/SNORM         # L/ 59M58.5S
                CCS     MPAC +1         # MAG OF MPAC = HI PART OF 59M58.5S
                TC      +2
                TC      M/SNORM         # MPAC+1 = +0. L/ 59M58.5S
                AD      M/SCON2         # - LO PART OF (59M58.5S) +1  FOR CCS
                CCS     A               # MAG OF MPAC+1 - LO PART OF (59M58.5S)
                TC      M/SLIMIT        # G/ 59M58.5S
                TC      M/SNORM         # ORIGINAL MPAC+1 = -0. L/ 59M58.5S
                TC      M/SNORM         # L/ 59M58.5S
M/SLIMIT        CCS     MPAC            # = 59M58.5S    LIMIT
                CAF     M/SCON3         # MPAC CANNOT BE +/- 0 AT THIS POINT.
                TC      +LIMIT          # FORCE MPAC, MPAC+1 TO +/- 59M59.5S
                CS      M/SCON3
                TS      MPAC            # WILL DISPLAY 59M59S IN DSPDECNR
                CS      M/SCON3 +1
LIMITCOM        TS      MPAC +1
                CAF     NORMADR         # SET RETURN TO M/SNORM+1.
                TC      SEPSECNR +1
+LIMIT          TS      MPAC
                CAF     M/SCON3 +1
                TC      LIMITCOM
M/SNORM         TC      SEPSEC          # LEAVE FRACT SEC/60 IN MPAC,MPAC+1. LEAVE
                                        # WHOLE MIN IN BIT13 OF LOTEMOUT AND ABOVE
                CAF     HISECON         # USE ONLY FRACT SEC/60 MOD 60
                TC      SHORTMP         # MULT BY .6 + 2EXP-14
                CS      THREE           # GIVES SEC/100 MOD 60
                ADS     DSPCOUNT        # DSPCOUNT ALREADY SET TO RXD1
                TC      BANKCALL        # DISPLAY SEC MOD 60 IN D4D5.
                CADR    DSPDC2NR
                CAF     ZERO
                TS      CODE
                CS      TWO
## Page 436
                INDEX   DECOUNT
                AD      R1D1            # RXD3
                TS      COUNT
                TC      BANKCALL        # BLANK MIDDLE CHAR
                CADR    DSPIN
                TC      SEPMIN          # REMOVE REST OF SECONDS
                XCH     MPAC +1         # LEAVE FRACT MIN/60 IN MPAC+1
                EXTEND                  # USE ONLY FRACT MIN/60 MOD 60
                MP      HIMINCON        # MULT BY .6 + 2EXP-7
                DXCH    MPAC            # GIVES MIN/100 MOD 60
                INDEX   DECOUNT
                CAF     R1D1            # RXD1
                TS      DSPCOUNT
                TC      BANKCALL        # DISPLAY MIN MOD 60 IN D1D2.
                CADR    DSPDC2NR
                TC      POSTJUMP
                CADR    DSPDCEND +2
                
HISECON         OCT     23147           # .6 + 2EXP-14
HIMINCON        OCT     23346           # .6 + 2EXP-7

M/SCON1         OCT     77753           # - HI PART OF (59M58.5S) +1
M/SCON2         OCT     41126           # - LO PART OF (59M58.5S) +1
NORMADR         ADRES   M/SNORM +1
M/SCON3         OCT     00025           # 59M 59.5S
                OCT     37016
                

SEPSEC          CCS     MPAC    +1      # IF +, ROUND BY ADDING .5 SEC
                TCF     POSEC           # IF -, ROUND BY SUBTRACTING .5 SEC
                TCF     POSEC           # FINDS TIME IN MPAC, MPAC+1
                TCF     +1              # ROUNDS OFF BY +/- .5 SEC
                EXTEND                  # LEAVES WHOLE MIN IN BIT13 OF
                DCS     RNDCON  -1      # LOTEMOUT AND ABOVE.
SEPSEC1         DAS     MPAC            # LEAVES FRACT SEC/60 IN MPAC, MPAC+1.
                TCF     SEPSECNR
POSEC           EXTEND
                DCA     RNDCON -1
                TCF     SEPSEC1
SEPSECNR        XCH     Q               # THIS ENTRY AVOIDS ROUNDING BY .5 SEC
                TS      SEPSCRET
                TC      DMP             # MULT BY 2EXP12/6000
                ADRES   SECON1          # GIVES FRACT SEC/60 IN BIT12 OF MPAC+1
                EXTEND                  # AND BELOW.
                DCA     MPAC            # SAVE MINUTES AND HOURS
                DXCH    HITEMOUT
                TC      TPSL1
                TC      TPSL1           # GIVES FRACT SEC/60 IN MPAC+1, MPAC+2.
                CAF     ZERO
                XCH     MPAC +2         # LEAVE FRACT SEC/60 IN MPAC, MPAC+1.
## Page 437
                XCH     MPAC +1
                XCH     MPAC
                TC      SEPSCRET

                
SEPMIN          XCH     Q               # FINDS WHOLE MINUTES IN BIT13
                TS      SEPMNRET        # OF LOTEMOUT AND ABOVE.
                CA      LOTEMOUT        # REMOVES REST OF SECONDS.
                EXTEND                  # LEAVES FRACT MIN/60 IN MPAC+1.
                MP      BIT3            # LEAVES WHOLE HOURS IN MPAC.
                EXTEND                  # SR 12, THROW AWAY LP.
                MP      BIT13           # SR 2, TAKE FROM LP. = SL 12.
                LXCH    MPAC +1         # THIS FORCES BITS 12-1 TO 0 IF +.
                                        # FORCES BITS 12-1 TO 1 IF -.
                CA      HITEMOUT
                TS      MPAC
                TC      DMP             # MULT BY 1/15
                ADRES   MINCON1         # GIVES FRACT MIN/60 IN MPAC+1.
ENDSPMIN        TC      SEPMNRET        # GIVES WHOLE HOURS IN MPAC.


# THIS IS A SPECIAL PURPOSE VERB FOR DISPLAYING A DOUBLE PRECISION AGC
# WORD AS 10 DECIMAL DIGITS ON THE AGC DISPLAY PANEL.  IT CAN BE USED WITH
# ANY NOUN, EXCEPT MIXED NOUNS. IT DISPLAYS THE CONTENTS
# OF THE REGISTER NOUNADD IS POINTING TO .  IF USED WITH NOUNS WHICH ARE
# INHERENTLY NOT DP SUCH AS THE CDU COUNTERS THE DISPLAY WILL BE GARBAGE.
# DISPLAY IS IN R1 AND R2 ONLY WITH THE SIGN IN R1.


                SETLOC  ENDRDLO +1

                COUNT*  $$/PIN
DSPDPDEC        INDEX   MIXBR
                TC      +0
                TC      +2              # NORMAL NOUN
                TC      DSPALARM
                EXTEND
                INDEX   NOUNADD
                DCA     0
                DXCH    MPAC
                CAF     R1D1
                TS      DSPCOUNT
                CAF     ZERO
                TS      MPAC +2
                TC      TPAGREE
                TC      DSP2DEC
ENDDPDEC        TC      ENTEXIT

## Page 438
# LOAD VERBS           IF ALARM CONDITION IS DETECTED DURING EXECUTE,
# CHECK FAIL LIGHT IS TURNED ON AND ENDOFJOB. IF ALARM CONDITION IS
# DETECTED DURING ENTER OF DATA, CHECK FAIL IS TURNED ON AND IT RECYCLES
# TO EXECUTE  OF ORIGINAL LOAD VERB. RECYCLE CAUSED BY  1) DECIMAL MACHINE
# CADR  2) MIXTURE OF OCTAL/DECIMAL DATA  3) OCTAL DATA INTO DECIMAL
# ONLY NOUN  4) DEC DATA INTO OCT ONLY NOUN  5) DATA TOO LARGE FOR SCALE
# 6) FEWER THAN 3 DATA WORDS LOADED FOR HRS, MIN, SEC NOUN.8(2)-(6) ALARM
# AND RECYCLE OCCUR AT FINAL ENTER OF SET. (1) ALARM AND RECYCLE OCCUR AT
# ENTER OF CADR.


                SETLOC  ENDRTOUT

                COUNT*  $$/PIN
ABCLOAD         CS      TWO
                TC      COMPTEST
                TC      NOUNTEST        # TEST IF NOUN CAN BE LOADED.
                CAF     VBSP1LD
                TC      UPDATVB -1
                TC      REQDATX
                CAF     VBSP2LD
                TC      UPDATVB -1
                TC      REQDATY
                CAF     VBSP3LD
                TC      UPDATVB -1
                TC      REQDATZ


PUTXYZ          CS      SIX             # TEST THAT THE 3 DATA WORDS LOADED ARE
                TC      ALLDC/OC        # ALL DEC OR ALL OCT.
                EXTEND
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                CAF     ZERO            # X COMP
                TC      PUTCOM
                INDEX   NOUNADD
                TS      0
                CAF     ONE             # Y COMP
                TC      PUTCOM
                INDEX   NOUNADD
                TS      1
                CAF     TWO             # Z COMP
                TC      PUTCOM
                INDEX   NOUNADD
                TS      2
                CS      SEVEN           # IF NOUN 7 HAS JUST BEEN LOADED, SET
                AD      NOUNREG         #  FLAG BITS AS SPECIFIED.
                EXTEND
                BZF     +2
                TC      LOADLV
## Page 439
                CA      XREG            # ECADR OF FLAG WORD.
                TC      SETNCADR +1     #  SET EBANK, NOUNADD.
                CA      ZREG            # ZERO TO RESET BITS, NON-ZERO TO SET BITS
                INHINT
                EXTEND
                BZF     BITSOFF
                INDEX   NOUNADD
                CS      0
                MASK    YREG            # BITS TO BE PROCESSED.
                INDEX   NOUNADD
                ADS     0               # SET BITS.
                TC      BITSOFF1
BITSOFF         CS      YREG            # BITS TO BE PROCESSED.
                INDEX   NOUNADD
                MASK    0
                INDEX   NOUNADD
                TS      0               # RESET BITS.
BITSOFF1        RELINT
                TC      LOADLV
                
ABLOAD          CS      ONE
                TC      COMPTEST
                TC      NOUNTEST        # TEST IF NOUN CAN BE LOADED.
                CAF     VBSP1LD
                TC      UPDATVB -1
                TC      REQDATX
                CAF     VBSP2LD
                TC      UPDATVB -1
                TC      REQDATY
PUTXY           CS      FIVE            # TEST THAT THE 2 DATA WORDS LOADED ARE
                TC      ALLDC/OC        # ALL DEC OR ALL OCT.
                EXTEND
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                CAF     ZERO            # X COMP
                TC      PUTCOM
                INDEX   NOUNADD
                TS      0
                CAF     ONE             # Y COMP
                TC      PUTCOM
                INDEX   NOUNADD
                TS      1
                TC      LOADLV
                
ALOAD           TC      REQDATX
                EXTEND
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                CAF     ZERO            # X COMP
                TC      PUTCOM
## Page 440
                INDEX   NOUNADD
                TS      0
                TC      LOADLV
                
BLOAD           CS      ONE
                TC      COMPTEST
                CAF     BIT15           # SET CLPASS FOR PASS0 ONLY
                TS      CLPASS
                TC      REQDATY
                EXTEND
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                CAF     ONE
                TC      PUTCOM
                INDEX   NOUNADD
                TS      1
                TC      LOADLV
                
CLOAD           CS      TWO
                TC      COMPTEST
                CAF     BIT15           # SET CLPASS FOR PASS0 ONLY
                TS      CLPASS
                TC      REQDATZ
                EXTEND
                DCA     LODNNLOC        # SWITCH BANKS TO NOUN TABLE READING
                DXCH    Z               # ROUTINE.
                CAF     TWO
                TC      PUTCOM
                INDEX   NOUNADD
                TS      2
                TC      LOADLV

LOADLV          CAF     ZERO
                TS      DECBRNCH
                CS      ZERO
                TS      LOADSTAT
                TC      RELDSP          # RELEASE FOR PRIORITY DISPLAY PROBLEM.
                CS      VD1             # TO BLOCK NUMERICAL CHARACTERS AND
                TS      DSPCOUNT        # CLEARS AFTER A COMPLETED LOAD
                TC      POSTJUMP        # AFTER COMPLETED LOAD, GO TO RECALTST
                CADR    RECALTST        # TO SEE IF THERE IS RECALL FROM ENDIDLE.
                
VBSP1LD         DEC     21              # VB21 = ALOAD
VBSP2LD         DEC     22              # VB22 = BLOAD
VBSP3LD         DEC     23              # VB23 = CLOAD


ALLDC/OC        TS      DECOUNT         # TESTS THAT DATA WORDS LOADED ARE EITHER
                CS      DECBRNCH        # ALL DEC OR ALL OCT. ALARMS IF NOT.
                TS      SR
## Page 441
                CS      SR
                CS      SR              # SHIFTED RIGHT 2
                CCS     A               # DEC COMP BITS IN LOW 3
                TCF     +2              # SOME ONES IN LOW 3
                TC      Q               # ALL ZEROS. ALL OCTAL.  OK
                AD      DECOUNT         # DEC COMP = 7 FOR 3COMP, =6 FOR 2COMP
                EXTEND                  # (BUT IT HAS BEEN DECREMENTED BY CCS)
                BZF     +2              # MUST MATCH 6 FOR 3COMP, 5 FOR 2COMP.
                TC      ALMCYCLE        # ALARM AND RECYCLE.
GOQ             TC      Q               # ALL REQUIRED ARE DEC.  OK


SFRUTNOR        XCH     Q               # GETS SF ROUTINE NUMBER FOR NORMAL CASE
                TS      EXITEM          # CANT USE L FOR RETURN. TSTFORDP USES L.
                CAF     MID5
                MASK    NNTYPTEM
                TC      RIGHT5
                TC      EXITEM          # SF ROUTINE NUMBER IN A
                
SFRUTMIX        XCH     Q               # GETS SF ROUTINE NUMBER FOR MIXED CASE
                TS      EXITEM
                INDEX   DECOUNT
                CAF     DISPLACE        # PUT TC GOQ, TC RIGHT5, OR TC LEFT5 IN L
                TS      L
                INDEX   DECOUNT
                CAF     LOW5            # LOW5, MID5, OR HI5 IN A
                MASK    RUTMXTEM        # GET HI5, MID5, OR LOW5 OF RUTMXTAB ENTRY
                INDEX   L
                TC      0
# DO TC GOQ(DECOUNT=0), DO TC RIGHT5(DECOUNT=1), DO TC LEFT5(DECOUNT=2).
SFRET1          TC      EXITEM          # SF ROUTINE NUMBER IN A

SFCONUM         XCH     Q               # GETS 2X(SF CONSTANT NUMBER)
                TS      EXITEM
                INDEX   MIXBR
                TC      +0
                TC      CONUMNOR        # NORMAL NOUN
                INDEX   DECOUNT         # MIXED NOUN
                CAF     DISPLACE
                TS      L               # PUT TC GOQ, TC RIGHT5, OR TC LEFT5 IN L
                INDEX   DECOUNT
                CAF     LOW5
                MASK    NNTYPTEM
                INDEX   L
                TC      0
# DO TC GOQ(DECOUNT=0), DO TC RIGHT5(DECOUNT=1), DO TC LEFT5(DECOUNT=2).
SFRET           DOUBLE                  # 2X(SF CONSTANT NUMBER ) IN A
                TC      EXITEM
                
DISPLACE        TC      GOQ
## Page 442
                TC      RIGHT5
                TC      LEFT5

CONUMNOR        CAF     LOW5            # NORMAL NOUN ALWAYS GETS LOW 5 OF
                MASK    NNTYPTEM        # NNTYPTAB FOR SF CONUM.
                DOUBLE
                TC      EXITEM          # 2X( SF CONSTANT NUMBER) IN A
                

PUTCOM          TS      DECOUNT
                XCH     Q
                TS      DECRET
                CAF     ZERO
                TS      MPAC+6
                INDEX   DECOUNT
                XCH     XREGLP
                TS      MPAC +1
                INDEX   DECOUNT
                XCH     XREG
                TS      MPAC
                INDEX   MIXBR
                TC      +0
                TC      PUTNORM         # NORMAL NOUN
# IF MIXNOUN, PLACE ADDRESS FOR COMPONENT K INTO NOUNADD, SET EBANK BITS.
                INDEX   DECOUNT         # GET IDADDTAB ENTRY FOR COMPONENT K
                CA      IDAD1TEM        #         OF NOUN.
                MASK    LOW11           # (ECADR)SUBK FOR CURRENT COMP OF NOUN
                TC      SETNCADR        # ECADR INTO NOUNCADR. SETS EB, NOUNADD.
                EXTEND                  # C(NOUNADD) IN A UPON RETURN
                SU      DECOUNT         # PLACE (ESUBK)-K INTO NOUNADD
                TS      NOUNADD
                CCS     DECBRNCH
                TC      PUTDECSF        # +  DEC
                TC      DCTSTCYC        # +0 OCTAL
                TC      SFRUTMIX        # TEST IF DEC ONLY BIT = 1. IF SO,
                TC      DPTEST          # ALARM AND RECYCLE. IF NOT, CONTINUE.
                TC      PUTCOM2         # NO DP
                                        # TEST FOR DP SCALE FOR OCT LOAD. IF SO,
                                        # +0 INTO MAJOR PART. SET NOUNADD FOR
                                        # LOADING OCTAL WORD INTO MINOR PART.
PUTDPCOM        INCR    NOUNADD         # DP  (ESUBK)-K+1  OR  E+1
                CA      NOUNADD         # NOUNADD NOW SET FOR MINOR PART
                ADS     DECOUNT         # (ESUBK)+1  OR  E+1  INTO DECOUNT
                CAF     ZERO            # NOUNADD SET FOR MINOR PART
                INDEX   DECOUNT
                TS      0 -1            # ZERO MAJOR PART(ESUBK OR E)
                TC      PUTCOM2

PUTNORM         TC      SETNADD         # ECADR FROM NOUNCADR. SETS EB, NOUNADD.
                CCS     DECBRNCH
## Page 443
                TC      PUTDECSF        # +  DEC
                TC      DCTSTCYC        # +0 OCTAL
                TC      SFRUTNOR        # TEST IF DEC ONLY BIT = 1. IF SO,
                TC      DPTEST          # ALARM AND RECYCLE. IF NOT, CONTINUE.
                TC      PUTCOM2 -4      # NO DP
                CAF     ZERO            # DP
                TS      DECOUNT
                TC      PUTDPCOM
                
                CA      NNADTEM
                AD      ONE             # IF NNADTEM = -1, CHANNEL TO BE SPECIFIED
                EXTEND
                BZF     CHANLOAD
PUTCOM2         XCH     MPAC
                TC      DECRET
                
                EBANK=  DSPCOUNT
GTSFINLC        2CADR   GTSFIN



CHANLOAD        CS      SEVEN           # DONT LOAD CHAN 7. (IT = SUPERBANK).
                AD      NOUNCADR
                EXTEND
                BZF     LOADLV
                CA      NOUNCADR
                MASK    LOW9
                XCH     MPAC
                EXTEND
                INDEX   MPAC
                WRITE   0
                TC      LOADLV
                

# PUTDECSF FINDS MIXBR AND DECOUNT STILL SET FROM PUTCOM

PUTDECSF        TC      SFCONUM         # 2X(SF CON NUMB) IN A
                TS      SFTEMP1
                EXTEND                  # SWITCH BANKS TO SF CONSTANT TABLE
                DCA     GTSFINLC        # READING ROUTINE.
                DXCH    Z               # LOADS SFTEMP1, SFTEMP2.
                INDEX   MIXBR
                TC      +0
                TC      PUTSFNOR
                TC      SFRUTMIX
                TC      PUTDCSF2
PUTSFNOR        TC      SFRUTNOR

PUTDCSF2        INDEX   A
                CAF     SFINTABR
## Page 444
                TC      BANKJUMP        # SWITCH BANKS FOR EXPANSHION ROOM
SFINTABR        CADR    GOALMCYC        # ALARM AND RECYCLE IF DEC LOAD
                                        # WITH OCTAL ONLY NOUN.
                CADR    BINROUND
                CADR    DEGINSF
                CADR    ARTHINSF
                CADR    DPINSF
                CADR    DPINSF2
                CADR    DSPALARM        # LRPOSOUT CANT BE LOADED.
                CADR    DPINSF          # SAME AS ARITHDP1
                CADR    HMSIN
                CADR    DSPALARM        # MIN/SEC CANT BE LOADED.
                CADR    DPINSF4
                CADR    ARTIN1SF
                CADR    DSPALARM        # 2INTOUT CANT BE LOADED.
                CADR    DEGINSF         # TESTS AT END FOR 360-CDU
ENDRUTIN        EQUALS


# SCALE FACTORS FOR THOSE ROUTINES NEEDING THEM ARE AVAILABLE IN SFTEMP1.
# ALL SFIN ROUTINES USE MPAC MPAC+1. LEAVE RESULT IN A. END WITH TC DECRET


                SETLOC  ENDDPDEC +1
                
                COUNT*  $$/PIN
# DEGINSF APPLIES 1000/180 =5.55555(10) = 5.43434(8)

DEGINSF         TC      DMP             # SF ROUTINE FOR DEC DEGREES
                ADRES   DEGCON1         # MULT BY 5.5  5(10)X2EXP-3
                CCS     MPAC +1         # THIS ROUNDS OFF MPAC+1 BEFORE SHIFT
                CAF     BIT11           # LEFT 3, AND CAUSES 360.00 TO OF/UF
                TC      +2              # WHEN SHIFTED LEFT AND ALARM.
                CS      BIT11
                AD      MPAC +1
                TC      2ROUND +2
                TC      TPSL1           # LEFT 1
DEGINSF2        TC      TPSL1           # LEFT 2
                TC      TESTOFUF
                TC      TPSL1           # RETURNS IF NO OF/UF (LEFT3)
                CCS     MPAC
                TC      SIGNFIX         # IF+, GO TO SIGNFIX
                TC      SIGNFIX         # IF +0, GO TO SIGNFIX
                COM                     # IF -,  USE -MAGNITUDE +1
                TS      MPAC            # IF -0, USE +0
SIGNFIX         CCS     MPAC+6  
                TC      SGNTO1          # IF OVERFLOW
                TC      ENDSCALE        # NO OVERFLOW/UNDERFLOW
                CCS     MPAC            # IF UF FORCE SIGN TO 0 EXCEPT -180
                TC      CCSHOLE
## Page 445
                TC      NEG180
                TC      +1
                XCH     MPAC
                MASK    POSMAX
                TS      MPAC
ENDSCALE        INDEX   MIXBR           # IF ROUTINE NO. IS NOT CDU DEGREES,
                TC      +0              #  THEN THIS IS 360 - CDU DEGREES
                TC      +3              #  AND ANGLE IN MPAC MUST BE REPLACED
                TC      SFMIXCAL        #  BY 360 DEGREES MINUS ITSELF.
MIXBACK         TC      +2
                TC      SFNORCAL
NORBACK         CS      A
                AD      BIT2
                EXTEND
                BZF     +2
                TC      360-CDU
ENDSCAL1        TC      POSTJUMP
                CADR    PUTCOM2
                
SFMIXCAL        TC      BANKCALL
                CADR    SFRUTMIX
                TC      MIXBACK

SFNORCAL        TC      BANKCALL
                CADR    SFRUTNOR
                TC      NORBACK
                
NEG180          CS      POSMAX
                TC      ENDSCALE -1
                
SGNTO1          CS      MPAC            # IF OF FORCE SIGN TO 1
                MASK    POSMAX
                CS      A
                TC      ENDSCALE -1
                
DEGCON1         2DEC    5.555555555 B-3


ARTHINSF        TC      DMP             # SCALES MPAC, +1 BY SFTEMP1, SFTEMP2.
                ADRES   SFTEMP1         # ASSUMES POINT BETWEEN HI AND LO PARTS
                XCH     MPAC +2         # OF SFCON. SHIFTS RESULTS LEFT BY 14.
                XCH     MPAC +1         # (BY TAKING RESULTS FROM MPAC+1, MPAC+2)
                XCH     MPAC
                EXTEND
                BZF     BINROUND
                TC      ALMCYCLE        # TOO LARGE A LOAD. ALARM AND RECYCLE.
BINROUND        TC      2ROUND
                TC      TESTOFUF
                TC      ENDSCAL1        # RETURNS IF NO OF/UF

## Page 446
ARTIN1SF        TC      DMP             # SCALES MPAC, +1 BY SFTEMP1, SFTEMP2.
                ADRES   SFTEMP1         # ROUNDS MPAC+1 INTO MPAC.
                TC      BINROUND
                

DPINSF          TC      DMP             # SCALES MPAC, MPAC +1 BY SFTEMP1,
                ADRES   SFTEMP1         # SFTEMP2.  STORES LOW PART OF RESULT
                XCH     MPAC +2         # IN (E SUBK) +1 OR E+1
                DOUBLE
                TS      MPAC +2
                CAF     ZERO
                AD      MPAC +1
                TC      2ROUND +2
                TC      TESTOFUF
                INDEX   MIXBR           # RETURNS IF NO OF/UF
                TC      +0
                TC      DPINORM
                CA      DECOUNT         # MIXED NOUN
DPINCOM         AD      NOUNADD         #      MIXED              NORMAL
                TS      Q               #   E SUBK            E
                XCH     MPAC +1
                INDEX   Q
                TS      1               # PLACE LOW PART IN
                TC      ENDSCAL1        # (E SUBK) +1    MIXED
                
DPINORM         CAF     ZERO            # E +1         NORMAL
                TC      DPINCOM

                
DPINSF2         TC      DMP             # ASSUMES POINT BETWEEN BITS 7-8 OF HIGH
                ADRES   SFTEMP1         # PART OF SF CONST. DPINSF2 SHIFTS RESULTS
                CAF     SIX             # LEFT BY 7, ROUNDS MPAC+2 INTO MPAC+1
                TC      TPLEFTN         # SHIFT LEFT 7.
                TC      DPINSF +2
                
DPINSF4         TC      DMP             # ASSUMES POINT BETWEEN BITS 11-12 OF HIGH
                ADRES   SFTEMP1         # PART OF SF CONST. DPINSF2 SHIFTS RESULTS
                CAF     TWO             # LEFT BY 3, ROUNDS MPAC+2 INTO MPAC+1.
                TC      TPLEFTN         # SHIFT LEFT 3.
                TC      DPINSF +2
                

TPLEFTN         XCH     Q               # SHIFTS MPAC, +1, +2 LEFT N. SETS OVFIND
                TS      SFTEMP2         # TO +1 FOR OF, -1 FOR UF.
                XCH     Q               # CALL WITH N-1 IN A.
LEFTNCOM        TS      SFTEMP1         #     LOOP TIME .37 MSEC.
                TC      TPSL1
                CCS     SFTEMP1
                TC      LEFTNCOM
## Page 447
                TC      SFTEMP2

                
2ROUND          XCH     MPAC     +1
                DOUBLE
                TS      MPAC    +1
                TC      Q               # IF MPAC+1 DOES NOT OF/UF
                AD      MPAC
                TS      MPAC
                TC      Q               # IF MPAC DOES NOT OF/UF
                TS      MPAC+6
2RNDEND         TC      Q


TESTOFUF        CCS     MPAC+6          # RETURNS IF NO OF/UF
                TC      ALMCYCLE        # OF   ALARM AND RECYCLE.
                TC      Q
                TC      ALMCYCLE        # UF   ALARM AND RECYCLE.
                

                SETLOC  ENDSPMIN +1
                
                COUNT*  $$/PIN
HMSIN           TC      ALL3DEC         # IF ALL 3 WORDS WERE NOT LOADED, ALARM.
                TC      DMP             # XREG, XREGLP (=HOURS) WERE ALREADY PUT
                ADRES   WHOLECON        # INTO MPAC, MPAC+1.
                TC      RND/TST         # ROUND OFF TO WHOLE HRS IN MPAC+1.
                CAF     ZERO            # ALARM IF MPAC NON ZERO (G/ 16383 ).
                TS      MPAC    +2
                CAF     HRCON
                TS      MPAC
                CAF     HRCON   +1
                XCH     MPAC    +1
                TC      SHORTMP
                TC      MPACTST         # ALARM IF MPAC NON ZERO (G/ 745)
                DXCH    MPAC    +1      # STORE HOURS CONTRIBUTION
                DXCH    HITEMIN
                CA      YREG            # PUT YREG, YREGLP INTO MPAC, +1.
                LXCH    YREGLP
                DXCH    MPAC
                TC      DMP
                ADRES   WHOLECON
                TC      RND/TST         # ROUND OFF TO WHOLE MIN IN MPAC+1
                CS      59MIN           # ALARM IF MPAC NON ZERO (G/16383)
                TC      SIZETST         # ALARM IF MPAC+1 G/ 59MIN
                XCH     MPAC    +1
                EXTEND
                MP      MINCON          # LEAVES MINUTES CONTRIBUTION IN A,L
                DAS     HITEMIN         # ADD IN MINUTES CONTRIBUTION
                EXTEND                  # IF THIS DAS OVERFLOWS, G/ 745 HR,39MIN
## Page 448
                BZF     +2
                TC      ALMCYCLE
                CA      ZREG            # PUT ZREG, ZREGLP INTO MPAC, +1.
                LXCH    ZREGLP
                DXCH    MPAC
                TC      DMP
                ADRES   WHOLECON
                TC      RND/TST         # ROUND OFF TO WHOLE CENTI-SEC IN MPAC+1
                CS      59.99SEC        # ALARM IF MPAC NON ZERO (G/163.83 SEC)
                TC      SIZETST         # ALARM IF MPAC+1 G/59.99 SEC
                DXCH    HITEMIN         # ADD IN SECONDS CONTRIBUTION
                DAS     MPAC            # IF THIS DAS OVERFLOWS,
                EXTEND                  # G/ 745 HR, 39 MIN, 14.55 SEC.
                BZF     +2
                TC      ALMCYCLE        # ALARM AND RECYCLE
                CAF     ZERO
                TS      MPAC +2
                TC      TPAGREE
                DXCH    MPAC
                INDEX   NOUNADD
                DXCH    0
                TC      POSTJUMP
                CADR    LOADLV

WHOLECON        OCT     00006           # (10EXP5/2EXP14)2EXP14
                OCT     03240
HRCON           OCT     00025           # 1 HOUR IN CENTI-SEC
                OCT     37100
MINCON          OCT     13560           # 1 MINUTE IN CENTI-SEC
59MIN           OCT     00073           # 59 AS WHOLE
59.99SEC        OCT     13557           # 5999 CENTI-SEC


RND/TST         XCH     MPAC +2         # ROUNDS MPAC+2 INTO MPAC+1.
                DOUBLE                  # ALARMS IF MPAC NOT 0
                TS      MPAC +2
                CAF     ZERO
                AD      MPAC +1
                TS      MPAC +1
                CAF     ZERO
                AD      MPAC            # CANT OVFLOW
                XCH     MPAC
MPACTST         CCS     MPAC            # ALARM IF MPAC NON ZERO
                TC      ALMCYCLE        # ALARM AND RECYCLE.
                TC      Q
                TC      ALMCYCLE        # ALARM AND RECYCLE.
                TC      Q
                
SIZETST         TS      MPAC +2         # CALLED WITH - CON IN A
                CCS     MPAC +1         # GET MAG OF MPAC+1
## Page 449
                AD      ONE
                TCF     +2
                AD      ONE
                AD      MPAC +2
                EXTEND                  # MAG OF MPAC+1 - CON
                BZMF    +2              
                TC      ALMCYCLE        # MAG OF MPAC+1 G/ CON. ALARM AND RECYCLE.
                TC      Q               # MAG OF MPAC+1 L/= CON
                

# ALL3DEC TESTS THAT ALL 3 WORDS ARE LOADED IN DEC (FOR HMSIN).
# ALARM IF NOT. (TEST THAT BITS 3,4,5 OF DECBRNCH ARE ALL = 1)
ALL3DEC         CS      OCT34BAR        # GET BITS 3,4,5 IN A
                MASK    DECBRNCH        # GET BITS 3,4,5 OF DECBRNCH IN A
                AD      OCT34BAR        # BITS 3,4,5 OF DECBRNCH MUST ALL = 1
                CCS     A
                TC      FORCEV25
OCT34BAR        OCT     77743
                TC      FORCEV25
                TC      Q
                
FORCEV25        CS      OCT31           # FORCE VERB 25 TO BE EXECUTED BY RECYCLE
                TS      VERBSAVE        #  IN CASE OPERATOR EXECUTED A LOWER LOAD
                TC      ALMCYCLE        #  VERB.  ALARM AND RECYCLE.
ENDHMSS         EQUALS

## Page 450
# MONITOR ALLOWS OTHER KEYBOARD ACTIVITY. IT IS ENDED BY VERB TERMINATE,
# VERB PROCEED WITHOUT DATA, VERB RESEQUENCE,
# ANOTHER MONITOR, OR ANY NVSUB CALL THAT PASSES THE DSPLOCK (PROVIDED
# THAT THE OPERATOR HAS SOMEHOW ALLOWED THE ENDING OF A MONITOR WHICH
# HE HAS INITIATED THROUGH THE KEYBOARD).

# MONITOR ACTION IS SUSPENDED, BUT NOT ENDED, BY ANY KEYBOARD ACTION,
# EXCEPT ERROR LIGHT RESET. IT BEGINS AGAIN WHEN KEY RELEASE IS PERFORMED.
# MONITOR SAVES THE NOUN AND APPROPRIATE DISPLAY VERB IN MONSAVE. IT SAVES
# NOUNCADR IN MONSAVE1, IF NOUN = MACHINE CADR TO BE SPECIFIED. BIT 15 OF
# MONSAVE1 IS THE KILL MONITOR SIGNAL (KILLER BIT). BIT 14 OF MONSAVE1
# INDICATES THE CURRENT MONITOR WAS EXTERNALLY INITIATED (EXTERNAL
# MONITOR BIT). IT IS TURNED OFF BY RELDSP AND KILMONON.

# MONSAVE INDICATES IF MONITOR IS ON(+=ON, +0=OFF)
# IF MONSAVE IS +, MONITOR ENTERS NO REQUEST, BUT TURNS KILLER BIT OFF.
# IF MONSAVE IS +0, MONITOR ENTERS REQUEST AND TURNS KILLER BIT OFF.

# NVSUB (IF EXTERNAL MONITOR BIT IS OFF), VB=PROCEED WITHOUT DATA,
# VB=RESEQUENCE, AND VB=TERMINATE TURN KILL MONITOR BIT ON.

# IF KILLER BIT IS ON, MONREQ ENTERS NO FURTHER REQUESTS, ZEROS MONSAVE
# AND MONSAVE1 (TURNING OFF KILLER BIT AND EXTERNAL MONITOR BIT).

# MONITOR DOSENT TEST FOR MATBS SINCE NVSUB CAN HANDLE INTERNAL MATBS NOW
                SETLOC  ENDRUTIN
                
                COUNT*  $$/PIN
MONITOR         CS      BIT15/14
                MASK    NOUNCADR
MONIT1          TS      MPAC +1         # TEMP STORAGE
                CS      ENTEXIT
                AD      ENDINST
                CCS     A
                TC      MONIT2
BIT15/14        OCT     60000
                TC      MONIT2
                CAF     BIT14           # EXTERNALLY INITIATED MONITOR.
                ADS     MPAC +1         # SET BIT 14 FOR MONSAVE1.
                CAF     ZERO
                TS      MONSAVE2        # ZERO NVMONOPT OPTIONS
MONIT2          CAF     LOW7
                MASK    VERBREG
                TC      LEFT5
                TS      CYL
                CS      CYL
                XCH     CYL
                AD      NOUNREG
                TS      MPAC            # TEMP STORAGE
                CAF     ZERO
## Page 451
                TS      DSPLOCK         # +0 INTO DSPLOCK SO MONITOR CAN RUN.
                CCS     CADRSTOR        # TURN OFF KR LITE IF CADRSTOR AND DSPLIST
                TC      +2              # ARE BOTH EMPTY. (LITE COMES ON IF NEW
                TC      RELDSP1         # MONITOR IS KEYED IN OVER OLD MONITOR.)
                INHINT
                CCS     MONSAVE
                TC      +5              # IF MONSAVE WAS +, NO REQUEST
                CAF     ONE             # IF MONSAVE WAS 0, REQUEST MONREQ
                TC      WAITLIST
                EBANK=  DSPCOUNT
                2CADR   MONREQ

                DXCH    MPAC            # PLACE MONITOR VERB AND NOUN INTO MONSAVE
                DXCH    MONSAVE         # ZERO THE KILL MONITOR BIT
                RELINT                  # SET UP EXTERNAL MONITOR BIT
                TC      ENTRET
                

MONREQ          TC      LODSAMPT        # CALLED BY WAITLIST
                CCS     MONSAVE1        # TIME IS SNATCHED IN RUPT FOR NOUN 65
                TC      +4              # IF KILLER BIT = 0, ENTER REQUESTS
                TC      +3              # IF KILLER BIT = 0, ENTER REQUESTS
                TC      KILLMON         # IF KILLER BIT = 1, NO REQUESTS
                TC      KILLMON         # IF KILLER BIT = 1, NO REQUESTS
                CAF     MONDEL
                TC      WAITLIST        # ENTER WAITLIST REQUEST FOR MONREQ
                EBANK=  DSPCOUNT
                2CADR   MONREQ
                
                CAF     CHRPRIO
                TC      NOVAC           # ENTER EXEC REQUEST FOR MONDO
                EBANK=  DSPCOUNT
                2CADR   MONDO
                
                TC      TASKOVER
                
KILLMON         CAF     ZERO            # ZERO MONSAVE AND TURN KILLER BIT OFF
                TS      MONSAVE
                TS      MONSAVE1        # TURN OFF KILL MONITOR BIT.
                TC      TASKOVER        # TURN OFF EXTERNAL MONITOR BIT.
MONDEL          OCT     144             # FOR 1 SEC MONITOR INTERVALS


MONDO           CCS     MONSAVE1        # CALLED BY EXEC
                TC      +4              # IF KILLER BIT = 0, CONTINUE
                TC      +3              # IF KILLER BIT = 0, CONTINUE
                TC      ENDOFJOB        # IN CASE TERMINATE CAME SINCE LAST MONREQ
                TC      ENDOFJOB        # IN CASE TERMINATE CAME SINCE LAST MONREQ
                CCS     DSPLOCK
                TC      MONBUSY         # NVSUB IS BUSY
## Page 452
                CAF     LOW7
                MASK    MONSAVE
                TC      UPDATNN -1      # PLACE NOUN INTO NOUNREG AND DISPLAY IT
                CAF     MID7
                MASK    MONSAVE         # CHANGE MONITOR VERB TO DISPLAY VERB
                AD      MONREF          # -DEC10, STARTING IN BIT8
                TS      EDOP            # RIGHT 7
                CA      EDOP
                TS      VERBREG
                CAF     MONBACK         # SET RETURN TO PASTEVB AFTER DATA DISPLAY
                TS      ENTRET
                CS      BIT15/14
                MASK    MONSAVE1        # PUT ECADR INTO MPAC +2. INTMCTBS WILL
                TS      MPAC +2         # DISPLAY IT AND SET NOUNCADR, NOUNADD,
ENDMONDO        TC      TESTNN          # EBANK.

                BLOCK   2
                
                SETLOC  FFTAG8
                BANK
                
                COUNT*  $$/PIN
PASTEVB         CAF     MID7
                MASK    MONSAVE2        # NVMONOPT PASTE OPTION
                EXTEND
                BZF     +2
                TC      PASTEOPT        # PASTE PLEASE VERB FOR NVMONOPT
                CA      MONSAVE         # PASTE MONITOR VERB - PASTE OPTION IS 0
PASTEOPT        TS      EDOP            # RIGHT 7
                CA      EDOP            # PLACE MONITOR VERB OR PLEASE VERB INTO
                TC      BANKCALL        #  VERBREG AND DISPLAY IT.
                CADR    UPDATVB -1
                CAF     ZERO            # ZERO REQRET SO THAT PASTED VERBS CAN
                TS      REQRET          #  BE EXECUTED BY OPERATOR.
                CA      MONSAVE2
                TC      BLANKSUB        # PROCESS NVMONOPT BLANK OPTION IF ANY
                TC      +1
ENDPASTE        TC      ENDOFJOB

MID7            OCT     37600

                SETLOC  ENDMONDO +1
                COUNT*  $$/PIN
MONREF          OCT     75377           # -DEC10, STARTING IN BIT8
MONBACK         ADRES   PASTEVB

MONBUSY         TC      RELDSPON        # TURN KEY RELEASE LIGHT
                TC      ENDOFJOB
## Page 453
# DSPFMEM IS USED TO DISPLAY (IN OCTAL) ANY FIXED REGISTER.
# IT IS USED WITH NOUN = MACHINE CADR TO BE SPECIFIED. THE FCADR OF THE 
# DESIRED LOCATION IS THEN PUNCHED IN. IT HANDLES F/F (FCADR 4000-7777)

# FOR BANKS L/E 27, THIS IS ENOUGH.

# FOR BANKS G/E 30, THE THIRD COMPONENT OF NOUN 26 (PRIO, ADRES, BBCON)
# MUST BE PRELOADED WITH THE DESIRED SUPERBANK BITS (BITS 5,6,7).
#          V23N26 SHOULD BE USED.

# SUMMARY
# FOR BANKS L/E 27,                          V27N01E(FCADR)E
# FOR BANKS G/E 30,    V23N26E(SUPERBITS)E   V27N01E(FCADR)E

DSPFMEM         CAF     R1D1            # IF F/F, DATACALL USES BANK 02 OR 03.
                TS      DSPCOUNT
                CA      DSPTEM1 +2      # SUPERBANK BITS WERE PRELOADED INTO
                TS      L               # 3RD COMPONENT OF NOUN 26.
                CA      NOUNCADR        # ORIGINAL FCADR LOADED STILL IN NOUNCADR.
                TC      SUPDACAL        # CALL WITH FCADR IN A, SUPERBITS IN L.
                TC      DSPOCTWO
ENDSPF          TC      ENDOFJOB

## Page 454
# WORD DISPLAY ROUTINES

                SETLOC  TESTOFUF +4
                COUNT*  $$/PIN
DSPSIGN         XCH     Q
                TS      DSPWDRET
                CCS     MPAC
                TC      +8D
                TC      +7
                AD      ONE
                TS      MPAC
                TC      -ON
                CS      MPAC +1
                TS      MPAC +1
                TC      DSPWDRET
                TC      +ON
                TC      DSPWDRET
                
DSPRND          EXTEND                  # ROUND BY 5 EXP-6
                DCA     DECROUND -1
                DAS     MPAC
                EXTEND
                BZF     +4
                EXTEND
                DCA     DPOSMAX
                DXCH    MPAC
                TC      Q
                
# DSPDECWD CONVERTS C( MPAC, MPAC+1) INTO A SIGN AND 5 CHAR DECIMAL
# STARTING IN LOC SPECIFIED IN DSPCOUNT. IT ROUNDS BY 5 EXP-6.

DSPDECWD        XCH     Q
                TS      WDRET
                TC      DSPSIGN
                TC      DSPRND
                CAF     FOUR
DSPDCWD1        TS      WDCNT
                CAF     BINCON
                TC      SHORTMP
TRACE1          INDEX   MPAC
                CAF     RELTAB
                MASK    LOW5
                TS      CODE
                CAF     ZERO
                XCH     MPAC +2
                XCH     MPAC +1
                TS      MPAC
                XCH     DSPCOUNT
TRACE1S         TS      COUNT
                CCS     A               # DECREMENT DSPCOUNT EXCEPT AT +0
## Page 455
                TS      DSPCOUNT
                TC      DSPIN
                CCS     WDCNT
                TC      DSPDCWD1
                CS      VD1
                TS      DSPCOUNT
                TC      WDRET
                
                OCT     00000
DECROUND        OCT     02476

# DSPDECNR CONVERTS C( MPAC,MPAC+1) INTO A SIGN AND 5 CHAR DECIMAL
# STARTING IN LOC SPECIFIED IN DSPCOUNT. IT DOES NOT ROUND

DSPDECNR        XCH     Q
                TS      WDRET
                TC      DSPSIGN
                TC      DSPDCWD1 -1

# DSPDC2NR CONVERTS C( MPAC,MPAC+1) INTO A SIGN AND 2 CHAR DECIMAL
# STARTING IN LOC SPECIFIED IN DSPCOUNT. IT DOES NOT ROUND

DSPDC2NR        XCH     Q
                TS      WDRET
                TC      DSPSIGN
                CAF     ONE
                TC      DSPDCWD1

                
# DSP2DEC CONVERTS C(MPAC) AND C(MPAC+1) INTO A SIGN AND 10 CHAR DECIMAL
# STARTING IN THE LOC SPECIFIED IN DSPCOUNT.

DSP2DEC         XCH     Q
                TS      WDRET
                CAF     ZERO
                TS      CODE
                CAF     THREE
                TC      11DSPIN         # -R2 OFF
                CAF     FOUR
                TC      11DSPIN         # +R2 OFF
                TC      DSPSIGN
                CAF     R2D1
END2DEC         TC      DSPDCWD1


# DSPDECVN DISPLAYS C(A) UPON ENTRY AS A 2 CHAR DECIMAL BEGINNING IN THE
# DSP LOC SPECIFIED IN DSPCOUNT.
# C(A) SHOULD BE IN FORM N X 2EXP-14. THIS IS SCALED TO FORM N/100 BEFORE
# DISPLAY CONVERSION.

## Page 456
DSPDECVN        EXTEND
                MP      VNDSPCON        # MULT BY .01
                LXCH    MPAC            # TAKE RESULTS FROM L.(MULT BY 2EXP14).
                CAF     ZERO
                TS      MPAC +1
                XCH     Q
                TS      WDRET
                TC      DSPDC2NR +3     # NO SIGN, NO ROUND, 2 CHAR
                
VNDSPCON        OCT     00244           # .01 ROUNDED UP


GOVNUPDT        TC      DSPDECVN        # THIS IS NOT FOR GENERAL USE. REALLY PART
                TC      POSTJUMP        # OF UPDATVB.
                CADR    UPDAT1 +2
                
ENDECVN         EQUALS


                SETLOC  ENDSPF +1
                COUNT*  $$/PIN
# DSPOCTWD DISPLAYS C(A) UPON ENTRY AS A 5 CHAR OCT STARTING IN THE DSP
# CHAR SPECIFIED IN DSPCOUNT. IT STOPS AFTER 5 CHAR HAVE BEEN DISPLAYED.

DSPOCTWO        TS      CYL
                XCH     Q
                TS      WDRET           # MUST USE SAME RETURN AS DSP2BIT.
                CAF     BIT14           # TO BLANK SIGNS
                ADS     DSPCOUNT
                CAF     FOUR
WDAGAIN         TS      WDCNT
                CS      CYL
                CS      CYL
                CS      CYL
                CS      A
                MASK    DSPMSK
                INDEX   A
                CAF     RELTAB
                MASK    LOW5
                TS      CODE
                XCH     DSPCOUNT
                TS      COUNT
                CCS     A               # DECREMENT DSPCOUNT EXCEPT AT +0
                TS      DSPCOUNT
                TC      POSTJUMP
                CADR    DSPOCTIN
OCTBACK         CCS     WDCNT
                TC      WDAGAIN         # +
DSPLV           CS      VD1             # TO BLOCK NUMERICAL CHARACTERS, CLEARS,
                TS      DSPCOUNT        # AND SIGNS AFTER A COMPLETED DISPLAY.
## Page 457
                TC      WDRET

DSPMSK          =       SEVEN


# DSP2BIT DISPLAYS C(A) UPON ENTRY AS A 2 CHAR OCT BEGINNING IN THE DSP
# LOC SPECIFIED IN DSPCOUNT BY PRE CYCLING RIGHT C(A) AND USING THE LOGIC
# OF THE 5 CHAR OCTAL DISPLAY

DSP2BIT         TS      CYR
                XCH     Q
                TS      WDRET
                CAF     ONE
                TS      WDCNT
                CS      CYR
                CS      CYR
                XCH     CYR
                TS      CYL
                TC      WDAGAIN +5


# FOR DSPIN PLACE 0/25 OCT INTO COUNT, 5 BIT RELAY CODE INTO CODE. BOTH
# ARE DESTROYED. IF BIT14 OF COUNT IS 1, SIGN IS BLANKED WITH LEFT CHAR.
# FOR DSPIN1 PLACE 0,1 INTO BIT11 OF CODE, 2 INTO COUNT, REL ADDRESS OF
# DSPTAB ENTRY INTO DSREL.

                SETLOC  ENDECVN
                
                COUNT*  $$/PIN
DSPIN           XCH     Q               # CANT USE L FOR RETURN, SINCE MANY OF THE 
                TS      DSEXIT          # ROUTINES CALLING DSPIN USE L AS RETURN.
                CAF     LOW5
                MASK    COUNT
                TS      SR
                XCH     SR
                TS      DSREL
                CAF     BIT1
                MASK    COUNT
                CCS     A
                TC      +2              # LEFT IF COUNT IS ODD
                TC      DSPIN1 -1       # RIGHT IF COUNT IS EVEN
                XCH     CODE
                TC      SLEFT5          # DOES NOT USE CYL
                TS      CODE
                CAF     BIT14
                MASK    COUNT
                CCS     A
                CAF     TWO             # BIT14 = 1, BLANK SIGN
                AD      ONE             # BIT14 = 0, LEAVE SIGN ALONE
                TS      COUNT           # +0 INTO COUNT FOR RIGHT
## Page 458
                                        # +1 INTO COUNT FOR LEFT(SIGN LEFT ALONE)
                                        # +3 INTO COUNT FOR LEFT(TO BLANK SIGN)
DSPIN1          INHINT
                INDEX   DSREL
                CCS     DSPTAB
                TC      +2              # IF +
                TC      CCSHOLE
                AD      ONE             # IF -
                TS      DSMAG
                INDEX   COUNT
                MASK    DSMSK
                EXTEND
                SU      CODE
                EXTEND
                BZF     DSLV            # SAME
DFRNT           INDEX   COUNT
                CS      DSMSK           # MASK WITH 77740,76037,75777, OR 74037
                MASK    DSMAG
                AD      CODE
                CS      A
                INDEX   DSREL
                XCH     DSPTAB
                EXTEND
                BZMF    DSLV            # DSPTAB ENTRY WAS -
                INCR    NOUT            # DSPTAB ENTRY WAS +
DSLV            RELINT
                TC      DSEXIT
                
DSMSK           OCT     37
                OCT     1740
                OCT     2000
                OCT     3740
                

# FOR 11DSPIN, PUT REL ADDRESSS OF DSPTAB ENTRY INTO A, 1 IN BIT11 OR 0 IN
# BIT11 OF CODE.

11DSPIN         TS      DSREL
                CAF     TWO
                TS      COUNT
                XCH     Q               # MUST USE SAME RETURN AS DSPIN
                TS      DSEXIT
                TC      DSPIN1

                
DSPOCTIN        TC      DSPIN           # SO DSPOCTWO DOESNT USE SWCALL
                CAF     +2
                TC      BANKJUMP
ENDSPOCT        CADR    OCTBACK

## Page 459
# DSPALARM FINDS TC NVSUBEND IN ENTRET FOR NVSUB INITIATED ROUTINES.
# ABORT WITH 01501.
# DSPALARM FINDS TC ENDOFJOB IN ENTRET FOR KEYBOARD INITIATED ROUTINES.
# DC TC ENTRET.

PREDSPAL        CS      VD1
                TS      DSPCOUNT
DSPALARM        CS      NVSBENDL
                AD      ENTEXIT
                EXTEND
                BZF     CHARALRM +2
                CS      MONADR          # IF THIS IS A MONITOR, KILL IT
                AD      ENTEXIT
                EXTEND
                BZF     +2
                TC      +2
                TC      KILMONON
CHARALRM        TC      FALTON          # NOT NVSUB INITIATED. TURN ON OPR ERROR
                TC      ENDOFJOB
                TC      POODOO
                OCT     01501
MONADR          GENADR  PASTEVB
NVSBENDL        TC      NVSUBEND


# ALMCYCLE TURNS ON CHECK FAIL LIGHT, REDISPLAYS THE ORIGINAL VERB THAT
# WAS EXECUTED, AND RECYCLES TO EXECUTE THE ORIGINAL VERB/NOUN COMBINATION
# THAT WAS LAST EXECUTED. USED FOR BAD DATA DURING LOAD VERBS AND BY
# MCTBS. ALSO BY MMCHANG IF 2 NUMERICAL CHARACTERS WERE NOT PUNCHED IN
# FOR MM CODE.

                SETLOC  MID7 +1
                COUNT*  $$/PIN
ALMCYCLE        TC      FALTON          # TURN ON CHECK FAIL LIGHT.
                CS      VERBSAVE        # GET ORIGINAL VERB THAT WAS EXECUTED
                TS      REQRET          # SET FOR ENTPAS0
                TC      BANKCALL        # PUTS ORIGINAL VERB INTO VERBREG AND
                CADR    UPDATVB -1      # DISPLAYS IT IN VERB LIGHTS.
                TC      POSTJUMP
ENDALM          CADR    ENTER


# MMCHANG USES NOUN DISPLAY UNTIL ENTER. THEN IT USES MODE DISP.
# IT GOES TO MODROUT WITH THE NEW M M CODE IN A, BUT NOT DISPLAYED IN
# MM LIGHTS.
# IT DEMANDS 2 NUMERICAL CHARACTERS BE PUNCHED IN FOR NEW MM CODE.
# IF NOT, IT RECYCLES.

                SETLOC  DSP2BIT +10D

## Page 460
                COUNT*  $$/PIN
MMCHANG         TC      REQMM           # ENTPASHI ASSUMES THE TC REQMM AT MMCHANG
                                        # IF THIS MOVES AT ALL, MUST CHANGE
                                        # MMADREF AT ENTPASHI.
                CAF     BIT5            # OCT20 = ND2.
                AD      DSPCOUNT        # DSPCOUNT MUST = -ND2.
                EXTEND                  # DEMAND THAT 2 NUM CHAR WERE PUNCHED IN.
                BZF     +2
                TC      ALMCYCLE        # DSPCOUNT NOT= -ND2. ALARM AND RECYCLE.
                CAF     ZERO            # DSPCOUNT = -ND2.
                XCH     NOUNREG
                TS      MPAC
                CAF     ND1
                TS      DSPCOUNT
                TC      BANKCALL
                CADR    2BLANK
                CS      VD1             # BLOCK NUM CHAR IN
                TS      DSPCOUNT
                CA      MPAC
                TC      POSTJUMP
                CADR    MODROUTB        # GO THRU STANDARD LOC.

                
MODROUTB        =       V37
REQMM           CS      Q
                TS      REQRET
                CAF     ND1
                TS      DSPCOUNT
                CAF     ZERO
                TS      NOUNREG
                TC      BANKCALL
                CADR    2BLANK
                TC      FLASHON
                CAF     ONE
                TS      DECBRNCH        # SET FOR DEC
                TC      ENTEXIT

                
# VBRQEXEC ENTERS REQUEST TO EXEC     FOR ANY ADDRESS WITH ANY PRIORITY.
# IT DOES ENDOFJOB AFTER ENTERING REQUEST. DISPLAY SYST IS RELEASED.
# IT ASSUMES NOUN 26 HAS BEEN PRELOADED WITH
# COMPONENT 1  PRIORITY(BITS 10-14) BIT1=0 FOR NOVAC, BIT1=1 FOR FINDVAC.
# COMPONENT 2  JOB ADRES (12 BIT )
# COMPONENT 3  BBCON

VBRQEXEC        CAF     BIT1
                MASK    DSPTEM1
                CCS     A
                TC      SETVAC          # IF BIT1 = 1, FINDVAC
                CAF     TCNOVAC         # IF BIT1 = 0, NOVAC
## Page 461
REQEX1          TS      MPAC            # TC NOVAC  OR  TC FINDVAC INTO MPAC
                CS      BIT1
                MASK    DSPTEM1
                TS      MPAC +4         # PRIO INTO MPAC+4 AS A TEMP
REQUESTC        TC      RELDSP
                CA      ENDINST
                TS      MPAC +3         # TC ENDOFJOB INTO MPAC+3
                EXTEND
                DCA     DSPTEM1 +1      # JOB ADRES INTO MPAC+1
                DXCH    MPAC +1         # BBCON INTO MPAC+2
                CA      MPAC +4         # PRIO IN A
                INHINT
                TC      MPAC

SETVAC          CAF     TCFINDVC
                TC      REQEX1
                
# VBRQWAIT ENTERS REQUEST TO WAITLIST FOR ANY ADDRESS WITH ANY DELAY.
# IT DOES ENDOFJOB AFTER ENTERING REQUEST.DISPLAY SYST IS RELEASED.
# IT ASSUMES NOUN 26 HAS BEEN PRELOADED WITH
# COMPONENT 1  DELAY (LOW BITS)
# COMPONENT 2  TASK ADRES (12 BIT)
# COMPONENT 3  BBCON

VBRQWAIT        CAF     TCWAIT
                TS      MPAC            # TC WAITLIST INTO MPAC
                CA      DSPTEM1         # TIME DELAY
ENDRQWT         TC      REQUESTC -1

# REQUESTC WILL PUT TASK ADRES INTO MPAC+1, BBCON INTO MPAC+2,
# TC ENDOFJOB INTO MPAC+3. IT WILL TAKE TIME DELAY OUT OF MPAC+4 AND
# LEAVE IT IN A, INHINT AND TC MPAC.

                SETLOC  NVSBENDL +1
                COUNT*  $$/PIN
VBPROC          CAF     ONE             # PROCEED WITHOUT DATA
                TS      LOADSTAT
                TC      KILMONON        # TURN ON KILL MONITOR BIT
                TC      RELDSP
                TC      FLASHOFF
                TC      RECALTST        # SEE IF THERE IS ANY RECALL FROM ENDIDLE
                

VBTERM          CS      ONE
                TC      VBPROC +1       # TERM VERB SETS LOADSTAT NEG
                
# PROCKEY PERFORMS THE SAME FUNCTION AS VBPROC.  IT MUST BE CALLED UNDER
# EXECUTIVE CONTROL, WITH CHRPRIO.

## Page 462
PROCKEY         CAF     ZERO            # SET REQRET FOR ENTER PASS 0.
                TS      REQRET
                CS      VD1             # BLOCK NUMERICAL CHARACTERS, SIGNS, CLEAR
                TS      DSPCOUNT
                TC      VBPROC

                
# VBRESEQ WAKES ENDIDLE AT SAME LINE AS FINAL ENTER OF LOAD (L+3).
# (MAIN USE IS INTENDED AS RESPONSE TO INTERNALLY INITIATED FLASHING
#  DISPLAYS IN ENDIDLE. SHOULD NOT BE USED WITH LOAD VERBS,PLEASE PERFORM,
#  OR PLEASE MARK VERBS BECAUSE THEY ALREADY USE L+3 IN ANOTHER CONTEXT.)

VBRESEQ         CS      ZERO            # MAKE IT LOOK LIKE DATA IN.
                TC      VBPROC +1

                
# FLASH IS TURNED OFF BY PROCEED WITHOUT DATA, TERMINATE, RESEQUENCE,
# END OF LOAD.

## Page 463
# KEY RELEASE ROUTINE

# THIS ROUTINE ALWAYS TURNS OFF THE UPACT LIGHT AND ALWAYS CLEARS DSPLOCK.

# THE HIGHEST PRIORITY FUNCTION OF THE KEY RELEASE BUTTON IS THE
# UNSUSPENDING OF A SUSPENDED MONITOR WHICH WAS EXTERNALLY INITIATED.
# THIS FUNCTION IS ACCOMPLISHED BY CLEARING DSPLOCK AND TURNING OFF
# THE KEY RELEASE LIGHT IF BOTH DSPLIST AND CADRSTOR ARE EMPTY.

# IF NO SUCH MONITOR EXISTS, THEN RELDSP IS EXECUTED TO CLEAR DSPLOCK
# AND THE EXTERNAL MONITOR BIT (FREEING THE DISPLAY SYSTEM FOR INTERNAL
# USE), TURN OFF THE KEY RELEASE LIGHT, AND WAKE UP ANY JOB IN DSPLIST.

# IN ADDITION IF THERE IS A JOB IN ENDIDLE, THEN CONTROL IS TRANSFERRED
# TO PINBRNCH (IN DISPLAY INTERFACE ROUTINE) TO RE-EXECUTE THE SERIES OF
# NVSUB CALLS ETC. THAT PRECEDED THE ENDIDLE CALL STILL AWAITING RESPONSE.
# THIS FEATURE IS INTENDED FOR USE WHEN THE OPERATOR HAS BEEN REQUESTED TO
# RESPOND TO SOME INTERNAL ACTION THAT USED ENDIDLE, BUT HE HAS WRITTEN
# OVER THE INFORMATION ON THE DISPLAY PANEL BY SOME DISPLAYS OF HIS OWN
# INITIATION WHICH DO NOT SERVE AS RESPONSES. HITTING KEY RLSE WILL
# RE-ESTABLISH THE DISPLAYS TO THE STATE THEY WERE IN BEFORE HE OBSCURED
# THEM, SO THAT HE CAN SEE THE WAITING REQUEST.  THIS WORKS ONLY FOR
# INTERNAL PROGRAMS THAT USED ENDIDLE THROUGH MARGARETS DISPLAY
# SUBROUTINES.

VBRELDSP        CS      BIT3
                EXTEND
                WAND    DSALMOUT        # TURN OFF UPACT LITE
                CCS     21/22REG        # OLD DSPLOCK
                CAF     BIT14
                MASK    MONSAVE1        # EXTERNAL MONITOR BIT (EMB)
                CCS     A
                TC      UNSUSPEN        # OLD DSPLOCK AND EMB BOTH 1, UNSUSPEND.
TSTLTS4         TC      RELDSP          # NOT UNSUSPENDING EXTERNAL MONITOR,
                CCS     CADRSTOR        #  RELEASE DISPLAY SYSTEM AND
                TC      +2              #  DO RE-ESTABLISH IF CADRSTOR IS FULL.
                TC      ENDOFJOB
                TC      POSTJUMP
                CADR    PINBRNCH
UNSUSPEN        CAF     ZERO            # EXTERNAL MONITOR IS SUSPENDED,
                TS      DSPLOCK         #  JUST UNSUSPEND IT BY CLEARING DSPLOCK.
                CCS     CADRSTOR        #  TURN KEY RELEASE LIGHT OFF IF BOTH
                TC      ENDOFJOB        #  CADRSTOR AND DSPLIST ARE EMPTY.
                TC      RELDSP1
                TC      ENDOFJOB
                
ENDRELDS        EQUALS

## Page 464
# NVSUB IS USED FOR SUB ROUTINE CALLS FROM WITHIN COMPUTER. IT CAN BE
# USED TO CALL THE COMBINATION OF ANY DISPLAY, LOAD, OR MONITOR VERB
# TOGETHER WITH ANY NOUN AVAILABLE TO THE KEYBOARD.
# PLACE 0VVVVVVVNNNNNNN INTO A.
# V-S ARE THE 7 BIT VERB CODE.  N-S ARE THE 7 BIT NOUN CODE.

# IF NVSUB IS CALLED WITH THE FOLLOWING NEGATIVE NUMBERS (RATHER THAN THE
# VERB-NOUN CODE) IN A, THEN THE DISPLAY IS BLANKED AS FOLLOWS-
#  -4 FULL BLANK, -3 LEAVE MODE, -2 LEAVE MODE AND VERB, -1 BLANK R-S ONLY

# NVSUB CAN BE USED WITH MACH CADR TO BE SPEC BY PLACING THE CADR INTO
# MPAC+2 BEFORE THE STANDARD NVSUB CALL.

#  NVSUB RETURNS TO 2+ CALLING LOC AFTER PERFORMING TASK, IF DISPLAY
# SYSTEM IS AVAILABLE. THE NEW NOUN AND VERB CODES ARE DISPLAYED.
# IF V:S =0, THE NEW NOUN CODE IS DISPLAYED ONLY(RETURN WITH NO FURTHER
# ACTION). IF N-S =0, THE NEW VERB CODE IS DISPLAYED ONLY(RETURN WITH NO
# FURTHER ACTION).

# IT RETURNS TO 1+ CALLING LOC WITHOUT PERFORMING TASK, IF DISPLAY
# SYSTEM IS BLOCKED (NOTHING IS DISPLAYED IN THIS CASE).
# IT DOES TC ABORT (WITH OCT 01501) IF IT ENCOUNTERS A DISPLAY PROGRAM
# ALARM CONDITION BEFORE RETURN TO CALLER.

# THE DISPLAY SYSTEM IS BLOCKED BY THE DEPRESSION OF ANY
# KEY, EXCEPT ERROR LIGHT RESET
# IT IS RELEASED BY THE KEY RELEASE BUTTON, ALL EXTENDED VERBS,
# PROCEED WITHOUT DATA, TERMINATE, RESEQUENCE, INITIALIZE EXECUTIVE,
# RECALL PART OF RECALTST IF ENDIDLE WAS USED,
# VB = REQUEST EXECUTIVE, VB = REQUEST WAITLIST,
# MONITOR SET UP.

# THE DISPLAY SYSTEM IS ALSO BLOCKED BY THE EXTERNAL MONITOR BIT, WHICH
# INDICATES AN EXTERNALLY INITIATED MONITOR IS RUNNING (SEE MONITOR)

# A NVSUB CALL THAT PASSES DSPLOCK AND THE EXTERNAL MONITOR BIT ENDS OLD
# MONITOR.

# DSPLOCK IS THE INTERLOCK FOR USE OF KEYBOARD AND DISPLAY SYSTEM WHICH
# LOCKS OUT INTERNAL USE WHENEVER THERE IS EXTERNAL KEYBOARD ACTION.

# NVSUB SHOULD BE USED TWICE IN SUCCESSION FOR :PLEASE PERFORM: SITUATIONS
# (SIMILARLY FOR PLEASE MARK). FIRST PLACE THE CODED NUMBER FOR WHAT
# ACTION IS DESIRED OF OPERATOR INTO THE REGISTERS REFERRED TO BY THE
# :CHECKLIST: NOUN. GO TO NVSUB WITH A DISPLAY VERB AND THE :CHECKLIST:
# NOUN. GO TO NVSUB AGAIN WITH THE :PLEASE PERFORM: VERB AND ZEROS IN THE
# LOW 7 BITS. THIS :PASTES UP: THE :PLEASE PERFORM: VERB INTO THE VERB
# LIGHTS.

# NVMONOPT IS AN ENTRY SIMILAR TO NVSUB, BUT REQUIRING AN ADDITIONAL
## Page 465
# PARAMETER IN L. IT SHOULD BE USED ONLY WITH A MONITOR VERB-NOUN CODE IN
# A. AFTER EACH MONITOR DISPLAY A *PLEASE* VERB WILL BE PASTED IN THE VERB
# LIGHTS OR DATA WILL BE BLANKED (OR BOTH) ACCORDING TO THE OPTIONS
# SPECIFIED IN L. IF BITS 8-14 OF L ARE OTHER THAN ZERO, THEN THEY WILL 
# BE INTERPRETED AS A VERB CODE AND PASTED IN THE VERB LIGHTS. (THIS VERB
# CODE SHOULD DESIGNATE ONE OF THE *PLEASE* VERBS.) IF BITS 1-3 OF L ARE
# OTHER THAN ZERO, THEN THEY WILL BE USED TO BLANK DATA BY BEING FED TO
# BLANKSUB. IF NVMONOPT IS USED WITH A VERB OTHER THAN A MONITOR VERB,
# THE PARAMETER IN L HAS NO EFFECT.

# NVSUB IN FIXED-FIXED PLACES 2+CALLING LOC INTO NVQTEM, TC NVSUBEND INTO
# ENTRET. (THIS WILL RESTORE OLD CALLING BANK BITS)

                SETLOC  ENDALM +1

                COUNT*  $$/PIN
NVSUB           LXCH    7               # ZERO NVMONOPT OPTIONS
NVMONOPT        TS      NVTEMP
                CAF     BIT14
                MASK    MONSAVE1        # EXTERNAL MONITOR BIT
                AD      DSPLOCK
                CCS     A
                TC      Q               # DSP SYST BLOCKED, RET TO 1+ CALLING LOC
                CAF     ONE             # DSP SYST AVAILABLE
NVSBCOM         AD      Q
                TS      NVQTEM          # 2+ CALLING LOC INTO NVQTEM
                LXCH    MONSAVE2        # STORE NVMONOPT OPTIONS
                TC      KILMONON        # TURN ON KILL MONITOR BIT
NVSUBCOM        CAF     NVSBBBNK

                XCH     BBANK
                EXTEND                  # SAVE OLD SUPERBITS
                ROR     SUPERBNK
                TS      NVBNKTEM
                CAF     PINSUPBT
                EXTEND
                WRITE   SUPERBNK
                TC      NVSUBB          # GO TO NVSUB1 THRU STANDARD LOC
                EBANK=  DSPCOUNT
NVSBBBNK        BBCON   NVSUB1

PINSUPBT        =       NVSBBBNK        # CONTAINS THE PINBALL SUPERBITS.

NVSUBEND        DXCH    NVQTEM          # NVBNKTEM MUST = NVQTEM+1
                TC      SUPDXCHZ        # DTCB WITH SUPERBIT SWITCHING
                
                SETLOC  ENDRQWT +1
                
                COUNT*  $$/PIN
# BLANKDSP BLANKS DISPLAY ACCORDING TO OPTION NUMBER IN NVTEMP AS FOLLOWS
## Page 466
#  -4 FULL BLANK, -3 LEAVE MODE, -2 LEAVE MODE AND VERB, -1 BLANK R-S ONLY

BLANKDSP        AD      SEVEN           # 7,8,9,OR 10 (A HAD 0,1,2,OR 3)
                INHINT
                TS      CODE            # BLANK SPECIFIED DSPTABS
                CS      BIT12
                INDEX   CODE
                XCH     DSPTAB
                CCS     A
                INCR    NOUT
                TC      +1
                CCS     CODE
                TC      BLANKDSP +2
                RELINT
                INDEX   NVTEMP
                TC      +5
                TC      +1              # NVTEMP HAS -4 (NEVER TOUCH MODREG)
                TS      VERBREG         #            -3
                TS      NOUNREG         #            -2
                TS      CLPASS          #            -1
                CS      VD1
                TS      DSPCOUNT
                TC      FLASHOFF        # PROTECT AGAINST INVISIBLE FLASH
                TC      ENTSET -2       # ZEROS REQRET
                
NVSUB1          CAF     ENTSET          # IN BANK
                TS      ENTRET          # SET RETURN TO NVSUBEND
                CCS     NVTEMP          # WHAT NOW
                TC      +4              # NORMAL NVSUB CALL (EXECUTE VN OR PASTE)
                TC      GODSPALM
                TC      BLANKDSP        # BLANK DISPLAY AS SPECIFIED
                TC      GODSPALM
                CAF     LOW7
                MASK    NVTEMP
                TS      MPAC +3         # TEMP FOR NOUN (CANT USE MPAC. DSPDECVN
                CA      NVTEMP          #                 USES MPAC, +1, +2
                TS      EDOP            # RIGHT 7
                CA      EDOP
                TS      MPAC +4         # TEMP FOR VERB (CANT USE MPAC+1. DSPDECVN
                                        #                USES MPAC, +1, +2).
                CCS     MPAC +3         # TEST NOUN
                TC      NVSUB2          # IF NOUN NOT +0, GO ON
                CA      MPAC +4 
                TC      UPDATVB -1      # IF NOUN = +0, DISPLAY VERB . THEN RETURN
                CAF     ZERO            # ZERO REQRET SO THAT PASTED VERBS CAN
                TS      REQRET          # BE EXECUTED BY OPERATOR.
ENTSET          TC      NVSUBEND
NVSUB2          CCS     MPAC +4         # TEST VERB
                TC      +4              # IF VERB NOT +0, GO ON
                CA      MPAC +3
## Page 467
                TC      UPDATNN -1      # IF VERB = +0, DISPLAY NOUN, THEN RETURN
                TC      NVSUBEND
                CA      MPAC +2         # TEMP FOR MACH CADR TO BE SPEC. (DSPDECVN
                TS      MPAC +5         #              USES MPAC, +1, +2)
                CA      MPAC +4
                TC      UPDATVB -1      # IF BOTH NOUN AND VERB NOT +0, DISPLAY
                CA      MPAC +3         # BOTH AND GO TO ENTPAS0.
                TC      UPDATNN -1
                CAF     ZERO
                TS      LOADSTAT        # SET FOR WAITING FOR DATA CONDITION
                TS      CLPASS
                TS      REQRET          # SET REQRET FOR PASS 0.
                CA      MPAC +5         # RESTORES MACH CADR TO BE SPEC TO MPAC+2
                TS      MPAC +2         # FOR USE IN INTMCTBS (IN ENTPAS0).
ENDNVSB1        TC      ENTPAS0


# IF INTERNAL MACH CADR TO BE SPECIFIED, MPAC+2 WILL BE PLACED INTO
# NOUNCADR IN ENTPAS0 (INTMCTBS ).


                SETLOC  NVSUBEND +2
                COUNT*  $$/PIN
                                        # FORCE BIT 15 OF MONSAVE1 TO 1.
KILMONON        CAF     BIT15           #    THIS IS THE KILL MONITOR BIT.
                TS      MONSAVE1        # TURN OFF BIT 14, THE EXTERNAL
                                        #  MONITOR BIT.
                TC      Q

                
# LOADSTAT  +0 INACTIVE(WAITING FOR DATA). SET BY NVSUB
#           +1  PROCEED NO DATA. SET BY SPECIAL VERB
#          -1 TERMINATE   SET BY SPECIAL VERB
#          -0    DATA IN      SET BY END OF LOAD ROUTINE
#             OR RESEQUENCE   SET BY VERB 32


# L  TO ENDIDLE  (FIXED FIXED)
# ROUTINES THAT REQUEST LOADS THROUGH NVSUB SHOULD USE ENDIDLE WHILE
# WAITING FOR THE DATA TO BE LOADED. ENDIDLE PUTS CURRENT JOB TO SLEEP.
# ENDIDLE CANNOT BE CALLED FROM ERASABLE OR F/F MEMORY,
# SINCE JOBSLEEP AND JOBWAKE CAN HANDLE ONLY FIXED BANKS.
# RECALTST TESTS LOADSTAT AND WAKES JOB UP TO,
# L+1      FOR TERMINATE
# L+2      FOR PROCEED WITHOUT DATA
# L+3      FOR DATA IN, OR RESEQUENCE
# IT DOES NOTHING IF LOADSTAT INDICATES WAITING FOR DATA.


# ENDIDLE ABORTS (WITH CODE 01206) IF A SECOND JOB ATTEMPTS TO GO TO SLEEP
## Page 468
# IN PINBALL. IN PARTICULAR, IF AN ATTEMPT IS MADE TO GO TO ENDIDLE WHEN
# 1) CADRSTOR NOT= +0. THIS IS THE CASE WHERE THE CAPACITY OF ENDIDLE IS
# EXCEEDED. (+-NZ INDICATE A JOB IS ALREADY ASLEEP DUE TO ENDIDLE.)
# 2) DSPLIST NOT= +0. THIS INDICATES A JOB IS ALREADY ASLEEP DUE TO
# NVSUBUSY.

ENDIDLE         LXCH    Q               # RETURN ADDRESS INTO L.
                TC      ISCADR+0        # ABORT IF CADRSTOR NOT= +0
                TC      ISLIST+0        # ABORT IF DSPLIST NOT= +0
                CA      L               # DONT SET DSPLOCK TO 1 SO CAN USE
                MASK    LOW10           # ENDIDLE WITH NVSUB INITIATED MONITOR.
                AD      FBANK           # SAME STRATEGY FOR CADR AS MAKECADR.
                TS      CADRSTOR
                TC      JOBSLEEP

                
ENDINST         TC      ENDOFJOB


ISCADR+0        CCS     CADRSTOR        # ABORTS (CODE 01206) IF CADRSTOR NOT= +0.
                TC      DSPABORT        # RETURNS IF CADRSTOR = +0.
                TC      Q
                TC      DSPABORT
                
ISLIST+0        CCS     DSPLIST         # ABORTS (CODE 01206) IF DSPLIST NOT= +0.
                TC      DSPABORT        # RETURNS IF DSPLIST = +0.
                TC      Q
DSPABORT        TC      POODOO
                OCT     01206

                
# JAMTERM ALLOWS PROGRAMS TO PERFORM THE TERMINATE FUNCTION.
# IT DOES ENDOFJOB.

JAMTERM         CAF     PINSUPBT
                EXTEND
                WRITE   SUPERBNK
                CAF     34DEC
                TS      REQRET          # LEAVE ENTER SET FOR ENTPASS0.
                CS      VD1
                TS      DSPCOUNT
                TC      POSTJUMP
                CADR    VBTERM
                
34DEC           DEC     34


# JAMPROC ALLOWS PROGRAMS TO PERFORM THE PROCEED/PROCEED WITHOUT DATA
# FUNCTION. IT DOES ENDOFJOB.

## Page 469
JAMPROC         CAF     PINSUPBT
                EXTEND
                WRITE   SUPERBNK
                CAF     33DEC
                TS      REQRET          # LEAVE ENTER SET FOR ENTPASS0.
                CS      VD1
                TS      DSPCOUNT
                TC      POSTJUMP
                CADR    VBPROC
                
33DEC           DEC     33


# BLANKSUB BLANKS ANY COMBINATION OF R1, R2, R3.
# CALL WITH BLANKING CODE IN A.
# BIT1=1 BLANKS R1, BIT2=1 BLANKS R2, BIT3=1 BLANKS R3.
# ANY COMBINATION OF THESE BITS IS ACCEPTED.

# DSPCOUNT IS RESTORED TO STATE IT WAS IN BEFORE BLANKSUB WAS EXECUTED.

BLANKSUB        MASK    SEVEN
                TS      NVTEMP          # STORE BLANKING CODE IN NVTEMP.
                CAF     BIT14
                MASK    MONSAVE1        # EXTERNAL MONITOR BIT
                AD      DSPLOCK
                CCS     A
                TC      Q               # DSP SYST BLOCKED. RET TO 1+ CALLING LOC
                INCR    Q               # DSP SYST AVAILABLE
                                        # SET RETURN FOR 2+ CALLING LOC
                CCS     NVTEMP
                TCF     +2
                TC      Q               # NOTHING TO BLANK. RET TO 2+ CALLING LOC
                LXCH    Q               # SET RETURN FOR 2 + CALLING LOC
                CAF     BLNKBBNK
                XCH     BBANK
                EXTEND
                ROR     SUPERBNK        # SAVE OLD SUPERBITS.
                DXCH    BUF
                CAF     PINSUPBT
                EXTEND
                WRITE   SUPERBNK
                TC      BLNKSUB1
                
                EBANK=  DSPCOUNT
BLNKBBNK        BBCON   BLNKSUB1
ENDBLFF         EQUALS

                SETLOC  ENDRELDS
                COUNT*  $$/PIN
BLNKSUB1        CA      DSPCOUNT        # SAVE OLD DSPCOUNT FOR LATER RESTORATION
## Page 470
                TS      BUF +2
                CAF     BIT1            # TEST BIT1. SEE IF R1 TO BE BLANKED.
                TC      TESTBIT
                CAF     R1D1
                TC      5BLANK -1
                CAF     BIT2            # TEST BIT 2. SEE IF R2 TO BE BLANKED.
                TC      TESTBIT
                CAF     R2D1
                TC      5BLANK -1
                CAF     BIT3            # TEST BIT3. SEE IF R3 TO BE BLANKED.
                TC      TESTBIT
                CAF     R3D1
                TC      5BLANK -1
                CA      BUF +2          # RESTORE DSPCOUNT TO STATE IT HAD
                TS      DSPCOUNT        #      BEFORE BLANKSUB.
                DXCH    BUF             # CALL L+2 DIRECTLY.
                TC      SUPDXCHZ +1     # DTCB WITH SUPERBIT SWITCHING

TESTBIT         MASK    NVTEMP          # NVTEMP CONTAINS BLANKING CODE.
                CCS     A
                TC      Q               # IF CURRENT BIT = 1, RETURN TO L+1.
                INDEX   Q               # IF CURRENT BIT = 0, RETURN TO L+3.
                TC      2
                
ENDBSUB1        EQUALS


# DSPMM DOES NOT DISPLAY MODREG DIRECTLY. IT PUTS IN EXEC REQUEST WITH
# PRIO 30000 FOR DSPMMJB AND RETURNS TO CALLER.

# IF MODREG CONTAINS -0, DSPMMJB BLANKS THE MODE LIGHTS.

# DSPMM MUST BE IN BANK 27 OR LOWER, SO IT CAN BE CALLED VIA BANKCALL.

                BANK    7
                SETLOC  PINBALL4
                BANK
                
                COUNT*  $$/PIN
DSPMM           XCH     Q
                TS      MPAC
                INHINT
                CAF     CHRPRIO
                TC      NOVAC
                EBANK=  DSPCOUNT
                2CADR   DSPMMJB
                
                RELINT
ENDSPMM         TC      MPAC

## Page 471
# DSPMM  PLACE MAJOR MODE CODE INTO MODREG

                SETLOC  ENDBSUB1
                
                COUNT*  $$/PIN
DSPMMJB         CAF     MD1             # GETS HERE THRU DSPMM
                XCH     DSPCOUNT
                TS      DSPMMTEM        # SAVE DSPCOUNT
                CCS     MODREG
                AD      ONE
                TC      DSPDECVN        # IF MODREG IS + OR +0, DISPLAY MODREG
                TC      +2              # IF MODREG IS -NZ, DO NOTHING
                TC      2BLANK          # IF MODREG IS -0, BLANK MM
                XCH     DSPMMTEM        # RESTORE DSPCOUNT
                TS      DSPCOUNT
                TC      ENDOFJOB
                

# RECALTST IS ENTERED DIRECTLY AFTER DATA IS LOADED (OR RESEQUENCE VERB IS
# EXECUTED), TERMINATE VERB IS EXECUTED, OR PROCEED WITHOUT DATA VERB IS
# EXECUTED. IT WAKES UP JOB THAT DID TC ENDIDLE.

# IF CADRSTOR NOT= +0, IT PUTS +0 INTO DSPLOCK, AND TURNS OFF KEY RLSE
# LIGHT IF DSPLIST IS EMPTY (LEAVES KEY RLSE LIGHT ALONE IF NOT EMPTY).

RECALTST        CCS     CADRSTOR
                TC      RECAL1
                TC      ENDOFJOB        # NORMAL EXIT IF KEYBOARD INITIATED
RECAL1          CAF     ZERO
                XCH     CADRSTOR
                INHINT
                TC      JOBWAKE
                CCS     LOADSTAT
                TC      DOPROC          # + PROCEED WITHOUT DATA
                TC      ENDOFJOB        # PATHALOGICAL CASE EXIT
                TC      DOTERM          # - TERMINATE
                CAF     TWO             # -0 DATA IN OR RESEQUENCE
RECAL2          INDEX   LOCCTR
                AD      LOC             # LOC IS + FOR BASIC JOBS
                INDEX   LOCCTR
                TS      LOC
                CA      NOUNREG         # SAVE VERB IN MPAC, NOUN IN MPAC+1 AT
                TS      L               # TIME OF RESPONSE TO ENDIDLE FOR
                CA      VERBREG         # POSSIBLE LATER TESTING BY JOB THAT HAS
                INDEX   LOCCTR          # BEEN WAKED UP.
                DXCH    MPAC
                RELINT
RECAL3          TC      RELDSP
                TC      ENDOFJOB
                
## Page 472
DOTERM          CAF     ZERO
                TC      RECAL2

DOPROC          CAF     ONE
                TC      RECAL2

## Page 473
# MISCELLANEOUS SERVICE ROUTINES IN FIXED/FIXED


                SETLOC  ENDBLFF

                COUNT*  $$/PIN
# SETNCADR       E CADR ARRIVES IN A. IT IS STORED IN NOUNCADR. EBANK BITS
#                ARE SET. E ADRES IS DERIVED AND PUT INTO NOUNADD.

SETNCADR        TS      NOUNCADR        # STORE ECADR
                TS      EBANK           # SET EBANK BITS
                MASK    LOW8
                AD      OCT1400
                TS      NOUNADD         # PUT E ADRES INTO NOUNADD
                TC      Q


# SETNADD        GETS E CADR FROM NOUNCADR, SETS EBANK BITS, DERIVES
#                E ADRES AND PUTS IT INTO NOUNADD.

SETNADD         CA      NOUNCADR
                TCF     SETNCADR +1


# SETEBANK       E CADR ARRIVES IN A. EBANK BITS ARE SET. E ADRES IS
#                DERIVED AND LEFT IN A.

SETEBANK        TS      EBANK           # SET EBANK BITS
                MASK    LOW8
                AD      OCT1400         # E ADRES LEFT IN A
                TC      Q


R1D1            OCT     16              # THESE 3 CONSTANTS FORM A PACKED TABLE.
R2D1            OCT     11              # DONT SEPARATE.
R3D1            OCT     4

RIGHT5          TS      CYR
                CS      CYR
                CS      CYR
                CS      CYR
                CS      CYR
                XCH     CYR
                TC      Q

LEFT5           TS      CYL
                CS      CYL
                CS      CYL
                CS      CYL
                CS      CYL
## Page 474
                XCH     CYL
                TC      Q

SLEFT5          DOUBLE
                DOUBLE
                DOUBLE
                DOUBLE
                DOUBLE
                TC      Q


LOW5            OCT     37              # THESE 3 CONSTANTS FORM A PACKED TABLE.
MID5            OCT     1740            # DONT SEPARATE.
HI5             OCT     76000           # MUST STAY HERE

TCNOVAC         TC      NOVAC
TCWAIT          TC      WAITLIST
TCTSKOVR        TC      TASKOVER
TCFINDVC        TC      FINDVAC


CHRPRIO         OCT     30000           # EXEC PRIORITY OF CHARIN


LOW11           OCT     3777
B12-1           EQUALS  LOW11
LOW8            OCT     377


VD1             OCT     23              # THESE 3 CONSTANTS FORM A PACKED TABLE.
ND1             OCT     21              # DONT SEPARATE.
MD1             OCT     25

BINCON          DEC     10

FALTON          CA      BIT7            # TURN ON OPERATOR ERROR LIGHT
                EXTEND
                WOR     DSALMOUT        # BIT 7 OF CHANNEL 11
                TC      Q

FALTOF          CS      BIT7            # TURN OFF OPERATOR ERROR LIGHT
                EXTEND
                WAND    DSALMOUT        # BIT 7 OF CHANNEL 11
                TC      Q

RELDSPON        CAF     BIT5            # TURN ON KEY RELEASE LIGHT
                EXTEND
                WOR     DSALMOUT        # BIT 5 OF CHANNEL 11
                TC      Q

## Page 475
LODSAMPT        EXTEND
                DCA     TIME2
                DXCH    SAMPTIME
                TC      Q


TPSL1           EXTEND                  # SHIFTS MPAC, +1, +2 LEFT 1
                DCA     MPAC +1         # LEAVES OVFIND SET TO +/- 1 FOR OF/UF
                DAS     MPAC +1
                AD      MPAC
                ADS     MPAC
                TS      7               # TS A DOES NOT CHANGE A ON OF/UF.
                TC      Q               # NO NET OF/UF
                TS      MPAC+6          # MPAC +6 SET TO +/-1 FOR OF/UF
                TC      Q


# IF MPAC, +1 ARE EACH +NZ OR +0 AND C(A)=-0, SHORTMP WRONGLY GIVES +0.
# IF MPAC, +1 ARE EACH -NZ OR -0 AND C(A)=+0, SHORTMP WRONGLY GIVES +0.
# PRSHRTMP FIXES FIRST CASE ONLY, BY MERELY TESTING C(A) AND IF IT = -0,
# SETTING RESULT TO -0.
#  (DO NOT USE PRSHRTMP UNLESS MPAC, +1 ARE EACH +NZ OR +0, AS THEY ARE
#  WHEN THEY CONTAIN TH E SF CONSTANTS.)

PRSHRTMP        TS      MPTEMP
                CCS     A
                CA      MPTEMP          # C(A) +, DO REGULAR SHORTMP
                TCF     SHORTMP +1      # C(A) +0, DO REGULAR SHORTMP
                TCF     -2              # C(A) -, DO REGULAR SHORTMP
                CS      ZERO            # C(A) -0, FORCE RESULT TO -0 AND RETURN.
                TS      MPAC
                TS      MPAC +1
                TS      MPAC +2
                TC      Q
                

FLASHON         CAF     BIT6            # TURN ON V/N FLASH
                EXTEND                  # BIT 6 OF CHANNEL 11
                WOR     DSALMOUT
                TC      Q

                
FLASHOFF        CS      BIT6            # TURN OFF V/N FLASH
                EXTEND
                WAND    DSALMOUT        # BIT 6 OF CHANNEL 11
                TC      Q
                
## Page 476
# INTERNAL USE OF KEYBOARD AND DISPLAY PROGRAM

# USER MUST SCHEDULE CALLS TO NVSUB SO THAT THERE IS NO CONFLICT OF USE OR
# CONFUSION TO OPERATOR. THE OLD GRABLOCK (INTERNAL/INTERNAL INTERLOCK)
# HAS BEEN REMOVED AND THE INTERNAL USER NO LONGER HAS THE PROTECTION THIS
# OFFERED.

# THERE ARE TWO WAYS A JOB CAN BE PUT TO SLEEP BY THE KEYBOARD + DISPLAY
# PROGRAM.    1) BY ENDIDLE
#             2) BY NVSUBUSY
# THE BASIC CONVENTION IS THAT ONLY ONE JOB WILL BE PERMITTED ASLEEP VIA
# THE KEYBOARD + DISPLAY PROGRAM AT A TIME. IF A JOB ATTEMPTS TO GO TO
# SLEEP BY MEANS OF (1) OR (2) AND THERE IS ALREADY A JOB ASLEEP THAT WAS
# PUT TO SLEEP BY (1) OR (2), THEN AN ABORT IS CAUSED.


# THE CALLING SEQUENCE FOR NVSUB IS
#          CAF    V/N
# L        TC     NVSUB
# L+1      RETURN HERE IF OPERATOR HAS INTERVENED
# L+2      RETURN HERE AFTER EXECUTION


#       A ROUTINE CALLED  NVSUBUSY IS PROVIDED (USE IS OPTIONAL)  TO PUT
# YOUR JOB TO SLEEP UNTIL THE OPERATOR RELEASES THE KEYBOARD + DISPLAY
# SYSTEM. NVSUBUSY ALSO TURNS ON THE KEY RELEASE LIGHT.
# NVSUBUSY CANNOT BE CALLED FROM ERASABLE OR F/F MEMORY,
# SINCE JOBSLEEP AND JOBWAKE CAN HANDLE ONLY FIXED BANKS.


#        THE CALLING SEQUENCE IS
#          CAF    WAKEFCADR
#          TC     NVSUBUSY


# .


# NVSUBUSY IS INTENDED FOR USE WHEN AN INTERNAL PROGRAM FINDS THE OPERATOR
# IS USING THE KEYBOARD + DISPLAY PROGRAM (BY HIS OWN INITIATION). IT IS
# NOT INTENDED FOR USE WHEN ONE INTERNAL PROGRAM FINDS ANOTHER INTERNAL 
# PROGRAM USING THE KEYBOARD + DISPLAY PROGRAM.


# NVSUBUSY ABORTS (WITH CODE 01206) IF A SECOND JOB ATTEMPTS TO GO TO
# SLEEP IN PINBALL. IN PARTICULAR, IF AN ATTEMPT IS MADE TO GO TO NVSUBUSY
# WHEN
# 1) DSPLIST NOT= +0. THIS IS THE CASE WHERE THE CAPACITY OF THE DSPLIST
#    IS EXCEEDED.
# 2) CADRSTOR NOT= +0. THIS INDICATES THAT A JOB IS ALREADY USING
## Page 477
# ENDIDLE. (+-NZ INDICATE A JOB IS ALREADY ASLEEP DUE TO ENDIDLE.)

PRENVBSY        CS      2K+3            # SPECIAL ENTRANCE FOR ROUTINES IN FIXED
                AD      Q               # BANKS ONLY DESIRING THE FCADR OF(LOC
                AD      FBANK           # FROM WHICH THE TC PRENVBSY WAS DONE) -2
NVSUBUSY        TC      POSTJUMP        # TO BE ENTERED.
                CADR    NVSUBSY1
2K+3            OCT     2003

# NVSUBSY1 MUST BE IN BANK 27 OR LOWER, SO IT WILL PUT CALLER TO SLEEP
# WITH HIS PROPER SUPERBITS.

                SETLOC  ENDSPMM +1
                COUNT*  $$/PIN
NVSUBSY1        TS      L
                TC      ISCADR+0        # ABORT IF CADRSTOR NOT= +0.
                TC      ISLIST+0        # ABORT IF DSPLIST NOT= +0.
                TC      RELDSPON
                CA      L
                TS      DSPLIST
ENDNVBSY        TC      JOBSLEEP


# NVSBWAIT IS A SPECIAL ENTRANCE FOR ROUTINES IN FIXED BANKS ONLY. IF
# SYSTEM IS NOT BUSY, IT EXECUTES V/N AND RETURNS TO L+1 (L= LOC FROM
# WHICH THE TC NVSBWAIT WAS DONE). IF SYSTEM IS BUSY, IT PUTS CALLING JOB
# TO SLEEP WITH L-1 GOING INTO LIST FOR EVENTUAL WAKING UP WHEN SYSTEM
# IS NOT BUSY.

                SETLOC  NVSUBUSY +3
                COUNT*  $$/PIN
NVSBWAIT        LXCH    7               # ZERO NVMONOPT OPTIONS
                TS      NVTEMP
                CAF     BIT14
                MASK    MONSAVE1        # EXTERNAL MONITOR BIT
                AD      DSPLOCK
                CCS     A
                TCF     NVSBWT1         # BUSY
                TCF     NVSBCOM         # FREE. NVSUB WILL SAVE L+1 FOR RETURN
                                        # AFTER EXECUTION.
NVSBWT1         INCR    Q               # L+2. PRENVBSY WILL PUT L-1 INTO LIST AND
                TCF     PRENVBSY        # GO TO SLEEP.

                
# RELDSP IS USED BY VBPROC, VBTERM, VBRQEXEC, VBRQWAIT, VBRELDSP, EXTENDED
# VERB DISPATCHER, VBRESEQ, RECALTST.
# RELDSP1 IS USED BY MONITOR SET UP, VBRELDSP.
RELDSP          XCH     Q               # SET DSPLOCK TO +0, TURN RELDSP LIGHT
                TS      RELRET          # OFF, SEARCH DSPLIST
                CS      BIT14
## Page 478
                INHINT
                MASK    MONSAVE1
                TS      MONSAVE1        # TURN OFF EXTERNAL MONITOR BIT
                CCS     DSPLIST
                TC      +2
                TC      RELDSP2         # LIST EMPTY
                CAF     ZERO
                XCH     DSPLIST
                TC      JOBWAKE
RELDSP2         RELINT
                CS      BIT5            # TURN OFF KEY RELEASE LIGHT
                EXTEND                  # (BIT 5 OF CHANNEL 11)
                WAND    DSALMOUT
                CAF     ZERO
                TS      DSPLOCK
                TC      RELRET
RELDSP1         XCH     Q               # SET DSPLOCK TO +0. NO DSPLIST SEARCH.
                TS      RELRET          # TURN KEY RLSE LIGHT OFF IF DSPLIST IS
                                        # EMPTY. LEAVE KEY RLSE LIGHT ALONE IF 
                                        # DSPLIST IS NOT EMPTY.
                CCS     DSPLIST
                TC      +2              # +  NOT EMPTY. LEAVE KEY RLSE LIGHT ALONE
                TC      RELDSP2         # +0 EMPTY. TURN OFF KEY RLSE LIGHT
                CAF     ZERO            # -  NOT EMPTY. LEAVE KEY RLSE LIGHT ALONE
                TS      DSPLOCK
                TC      RELRET
                

ENDPINBF        EQUALS

## Page 479
# PINTEST IS NEEDED FOR AUTO CHECK OF PINBALL.

PINTEST         EQUALS  LST2FAN

## Page 480
# VBTSTLTS TURNS ON ALL DISPLAY PANEL LIGHTS. AFTER 5 SEC, IT TURNS
# OFF THE CAUTION AND STATUS LIGHTS.

                SETLOC  ENDNVSB1 +1
                
                COUNT*  $$/PIN
VBTSTLTS        INHINT
                CS      BIT1            # SET BIT 1 OF IMODES33 SO IMUMON WONT
                MASK    IMODES33        # TURN OUT ANY LAMPS.
                AD      BIT1
                TS      IMODES33
                
                CAF     TSTCON1         # TURN ON UPLINK ACTIVITY, TEMP, KEY RLSE,
                EXTEND                  # V/N FLASH, OPERATOR ERROR.
                WOR     DSALMOUT
                CAF     TSTCON2         # TURN ON NO ATT, GIMBAL LOCK, TRACKER,
                TS      DSPTAB +11D     # PROG ALM.
                CAF     BIT10           # TURN ON TEST ALARM OUTBIT
                EXTEND
                WOR     CHAN13
                CAF     TEN
TSTLTS1         TS      ERCNT
                CS      FULLDSP
                INDEX   ERCNT
                TS      DSPTAB
                CCS     ERCNT
                TC      TSTLTS1
                CS      FULLDSP1
                TS      DSPTAB +1       # TURN ON 3 PLUS SIGNS
                TS      DSPTAB +4
                TS      DSPTAB +6
                CAF     ELEVEN
                TS      NOUT
                RELINT
                CAF     SHOLTS
                INHINT
                TC      WAITLIST
                EBANK=  DSPTAB
                2CADR   TSTLTS2
                
                TC      ENDOFJOB        # DSPLOCK IS LEFT BUSY (FROM KEYBOARD
                                        # ACTION) UNTIL TSTLTS3 TO INSURE THAT
                                        # LIGHTS TEST WILL BE SEEN.
                                        

FULLDSP         OCT     05675           # DISPLAY ALL 8:S
FULLDSP1        OCT     07675           # DISPLAY ALL 8:S AND +
TSTCON1         OCT     00175
                                        # UPLINK ACTIVITY, TEMP. KEY RLSE,
                                        # V/N FLASH, OPERATOR ERROR.
## Page 481
TSTCON2         OCT     40674           # DSPTAB+11D BITS 3,4,5,6,8,9, LR LITES,
                                        # NO ATT, GIMBAL LOCK, TRACKER, PROG ALM.
TSTCON3         OCT     00115           # CHAN 11  BITS 1, 3, 4, 7.
                                        # UPLINK ACTIVITY, TEMP, OPERATOR ERROR.
SHOLTS          OCT     764             # 5 SEC
                

TSTLTS2         CAF     CHRPRIO         # CALLED BY WAITLIST
                TC      NOVAC
                EBANK=  DSPTAB
                2CADR   TSTLTS3
                
                TC      TASKOVER

                
TSTLTS3         CS      TSTCON3         # CALLED BY EXECUTIVE
                INHINT
                EXTEND                  # TURN OFF  UPLINK ACTIVITY, TEMP,
                WAND    DSALMOUT        # OPERATOR ERROR.
                CS      BIT10           # TURN OFF TEST ALARM OUTBIT
                EXTEND
                WAND    CHAN13
                CAF     BIT4            # MAKE NO ATT FOLLOW BIT 4 OF CHANNEL 12
                EXTEND                  #   (NO ATT LIGHT ON IF IN COARSE ALIGN)
                RAND    CHAN12
                AD      BIT15           # TURN OFF AUTO, HOLD, FREE, SPARE,
                TS      DSPTAB +11D     # GIMBAL LOCK, SPARE, TRACKER, PROG ALM
                CS      13-11,1         # SET BITS TO INDICATE ALL LAMPS OUT. TEST
                MASK    IMODES33        # LIGHTS COMPLETE.
                AD      PRIO16
                TS      IMODES33
                
                CS      OCT55000
                MASK    IMODES30
                AD      PRIO15          # 15000.
                TS      IMODES30
                
                CS      RFAILS2
                MASK    RADMODES
                AD      RCDUFBIT
                TS      RADMODES
                
                RELINT
                
                TC      BANKCALL        # REDISPLAY C(MODREG)
                CADR    DSPMM
                TC      KILMONON        # TURN ON KILL MONITOR BIT.
                TC      FLASHOFF        # TURN OFF V/N FLASH.
                TC      POSTJUMP        # DOES RELDSP AND GOES TO PINBRNCH IF
                CADR    TSTLTS4         #  ENDIDLE IS AWAITING OPERATOR RESPONSE.
## Page 482
13-11,1         OCT     16001
RFAILS2         OCT     330             # RADAR CDU AND DATA FAIL FLAGS.
OCT55000        OCT     55000
ENDPINS2        EQUALS

## Page 483
# ERROR LIGHT RESET (RSET) TURNS OFF:
# UPLINK ACTIVITY, AUTO, HOLD, FREE, OPERATOR ERROR,
# PROG ALM, TRACKER FAIL.
# LEAVES GIMBAL LOCK AND NO ATT ALONE.
# IT ALSO ZEROES THE :TEST ALARM: OUT BIT, WHICH TURNS OFF STBY,RESTART.
# IT ALSO SETS :CAUTION RESET: TO 1.
# IT ALSO FORCES BIT 12 OF ALL DSPTAB ENTRIES TO 1.

                SETLOC  DOPROC +2
                COUNT*  $$/PIN
ERROR           XCH     21/22REG        # RESTORE ORIGINAL C(DSPLOCK). THUS ERROR
                TS      DSPLOCK         # LIGHT RESET LEAVES DSPLOCK UNCHANGED.
                INHINT
                CAF     BIT10           # TURN ON :CAUTION RESET: OUTBIT
                EXTEND
                WOR     DSALMOUT        # BIT10 CHAN 11
                CAF     GL+NOATT        # LEAVE GIMBAL LOCK AND NO ATT INTACT,
                MASK    DSPTAB +11D     # TURNING OFF AUTO, HOLD, FREE,
                AD      BIT15           # PROG ALARM, AND TRACKER.
                TS      DSPTAB +11D
                CS      PRIO16          # RESET FAIL BITS WHICH GENERATE PROG
                MASK    IMODES33        # ALARM SO THAT IF THE FAILURE STILL
                AD      PRIO16          # EXISTS, THE ALARM WILL COME BACK.
                TS      IMODES33
                CS      BIT10
                MASK    IMODES30
                AD      BIT10
                TS      IMODES30
                
                CS      RFAILS
                MASK    RADMODES
                AD      RCDUFBIT
                TS      RADMODES
                
                CS      BIT10           # TURN OFF :TEST ALARM: OUTBIT.
                EXTEND
                WAND    CHAN13
                CS      ERCON           # TURN OFF UPLINK ACTIVITY,
                EXTEND                  # OPERATOR ERROR.
                WAND    DSALMOUT
TSTAB           CAF     BINCON          # (DEC 10)
                TS      ERCNT           # ERCNT = COUNT
                INHINT
                INDEX   ERCNT
                CCS     DSPTAB
                AD      ONE
                TC      ERPLUS
                AD      ONE
ERMINUS         CS      A
                MASK    NOTBIT12
## Page 484
                TC      ERCOM
ERPLUS          CS      A
                MASK    NOTBIT12
                CS      A               # MIGHT WANT TO RESET CLPASS, DECBRNCH,
ERCOM           INDEX   ERCNT           # ETC.
                TS      DSPTAB
                RELINT
                CCS     ERCNT
                TC      TSTAB   +1
                CAF     ZERO
                TS      FAILREG
                TS      FAILREG +1
                TS      FAILREG +2
                TS      SFAIL
                TC      ENDOFJOB

ERCON           OCT     104             # CHAN 11 BITS 3,7.
                                        # UPLINK ACTIVITY, AND OPERATOR ERROR.
RFAILS          OCT     330             # RADAR CDU AND DATA FAIL FLAGS.
GL+NOATT        OCT     00050           # NO ATT AND GIMBAL LOCK LAMPS
NOTBIT12        OCT     73777


ENDPINS1        EQUALS


                SBANK=  LOWSUPER
