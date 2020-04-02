C PROGRAM TO SUBSTRACT TWO DATA SETS WITH PHASES
C USED TO GENERATE TIME DEPENDEND PHASES FROM MOCK DATA
C      CAN ALSO BE USED TO GENERATE PURE INTERMEDIATE DIFF STR. FACTORS
C TYPICAL INPUT
C MOCK FC DATA SCALED TO FC DARK : MOCK1_sm.hkl 
C MOCK FC PHASES                 : MOCK1.phs
C DARK FC AMPLITUDES AND PHASES  : 2phy_5dk.phs
C SEE SCHMIDT et al., 2003, Biophys J.

C
C READ MOCK DATA SCALED TO DARK
C FILE: H K L F SIGMA
C
      DIMENSION FL(-80:80,-80:80,-80:80,2)
      CHARACTER*80 FM_SM,FM_PHS,FDARK,FDIFF

      WRITE(*,200) ' ENTER MOCK DATA SCALED TO DARK : '
      READ(*,100) FM_SM
      WRITE(*,300) FM_SM(1:40)

      WRITE(*,200) ' ENTER MOCK DATA PHASE FILE     : '
      READ(*,100) FM_PHS
      WRITE(*,300) FM_PHS(1:40)

      WRITE(*,200) ' ENTER DARK + PHASES DATA SET   : '
      READ(*,100) FDARK
      WRITE(*,300) FDARK(1:40)

      WRITE(*,200) ' OUTPUT DATA                    : '
      READ(*,100) FDIFF
      WRITE(*,300) FDIFF(1:40)

100   FORMAT(A)
200   FORMAT(A,$)
300   FORMAT(' FILE : ',A40)
      PI2A=0.017453293
      IN = 10
      OPEN(UNIT=IN,FILE=FM_SM,STATUS='OLD',ERR=2500)
      I=0
900   CONTINUE
C CHANGE HERE FOR MOCK ==========>   <======= FCD-FCL
C      READ(IN,*,END=1000) IH,K,L,DUM,FSM
      READ(IN,*,END=1000) IH,K,L,FSM,DUM,DUM
      I=I+1
      FL(IH,K,L,1)=FSM
      GOTO 900
1000  CONTINUE
      CLOSE(IN)

C READ MOCK DATA PHASES 
      OPEN(UNIT=IN,FILE=FM_PHS,STATUS='OLD',ERR=2600)
      I=0
1200  CONTINUE
      READ(IN,*,END=1500) IH,K,L,DUM,DUM,FPHS
      I=I+1
      FL(IH,K,L,2)=FPHS*PI2A
      GOTO 1200
1500  CONTINUE
      CLOSE(IN)

C READ DARK DATA AMPLITUDES AND PHASES
      IOUT=11
      OPEN(UNIT=IN,FILE=FDARK,STATUS='OLD',ERR=2700)
      OPEN(UNIT=IOUT,FILE=FDIFF)
      I=0
1700  CONTINUE
C          hkl fc 0 phs ==========>    <====== hkl fo fc phs
C       READ(IN,*,END=2200) IH,K,L,DUM,FCD,PHICD
       READ(IN,*,END=2200) IH,K,L,FCD,DUM,PHICD
      IF (FL(IH,K,L,1).NE.0) THEN
        I=I+1
        PHICD=PHICD*PI2A
        FRD=FCD*COS(PHICD)
        FID=FCD*SIN(PHICD)
        FRL=FL(IH,K,L,1)*COS(FL(IH,K,L,2))
        FIL=FL(IH,K,L,1)*SIN(FL(IH,K,L,2))
        TPR=FRL-FRD
        TPI=FIL-FID
        IF (TPR.EQ.0.0) THEN
          IF (TPI.GT.0.0) PHI=90.0
          IF (TPI.LT.0.0) PHI=-90.0
        ELSE IF (TPI.EQ.0.0) THEN
          IF (TPR.GT.0.0) PHI=0.0
          IF (TPR.LT.0.0) PHI=180.0
        ELSE
          PHI=ATAN(TPI/TPR)/PI2A
          IF (TPR.LT.0.0) PHI=180.0+PHI
          IF (PHI.GT.180.0) PHI=PHI-360.0
        ENDIF
        FOUT=SQRT(TPR**2+TPI**2)

       WRITE(IOUT,2000) IH,K,L,FOUT,1.0,PHI
 2000  FORMAT(3I5,3F9.3)
      ENDIF
      GOTO 1700
 2200 CONTINUE
      GOTO 3000

 2500 WRITE(*,*) ' SCALED MOCK DATA SET DOES NOT EXIST ' 
        GOTO 3000           
 2600 WRITE(*,*) ' MOCK PHASES DATA SET DOES NOT EXIST '  
        GOTO 3000
 2700 WRITE(*,*) ' DARK DATA SET DOES NOT EXIST '
 3000 CONTINUE
      CLOSE(IN)
      CLOSE(IOUT)

      END

