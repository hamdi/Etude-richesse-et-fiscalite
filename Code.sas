/* Copie de la base dans Work */
libname memoire "C:\M�moire";
data ess;
set memoire.travail;
run;


/* Recodage synth�tique des revenus et de l'efficacit� des autorit�s */

data ess;
set ess;
if hinctnta in (1,2,3) then revenu=1;
if hinctnta in (4,5,6) then revenu=2;
if hinctnta in (7,8) then revenu=3;
if hinctnta in (9,10) then revenu=4;
if TXAUTEF in (0,1,2,3) then Efficacite=1;
if TXAUTEF in (4,5,6) then Efficacite=2;
if TXAUTEF in (7,8,9,10) then Efficacite=3;
if hinctnta in (1,2,3) then revenus=1;
if hinctnta in (9,10) then revenus=2;
attrib Revenu label="Revenu total net du m�nage";
attrib SMDFSLV label="Pour une soci�t� juste, les diff�rences de niveau de vie doivent �tre faibles";
attrib EARNPEN label="Les personnes � revenus plus �lev�s ou plus faibles doivent toucher une pension de retraite plus �lev�e";
attrib Efficacite label="Efficacit� des autorit�s fiscales";
run;


/* D�finition de formats clarifiant les modalit�s des variables */

Proc format;
value SMDFSLV
1 = "Fortement d'accord"
2 = "D'accord"
3 = "Neutre"
4 = "En d�saccord"
5 = "Fortement en d�saccord";
run;

Proc format;
value EARNPEN
1 = "Revenus �lev�s"
2 = "Pension �gale"
3 = "Revenus faibles";
run;

Proc format;
value Efficacite
1 = "Inefficace"
2 = "Neutre"
3 = "Efficace";
run;

Proc format;
value Revenu /* Version � 4 modalit�s */
1 = "Faible"
2 = "Moyen-faible"
3 = "Moyen-�lev�"
4 = "Elev�";
run;

Proc format;
value Revenus /* Version � 2 modalit�s */
1 = "Faible"
2 = "Elev�";
run;

Proc format;
value TXEARN
1 = "Payer la m�me pourcentage des revenus en taxes"
2 = "Les personnes � hauts revenus paient un pourcentage plus �lev�s en taxes"
3 = "Payer le m�me montant de taxes";
run;

Proc format;
value INSFBEN
1 = "Fortement d'accord"
2 = "D'accord"
3 = "Neutre"
4 = "En d�saccord"
5 = "Fortement en d�saccord";
run;


/* Cr�ation d'une variable pspwght1 pour contourner la pond�ration 'freq=' de gchart qui tronque la variable de pond�ration en un entier */
data ess;
set ess;
pspwght1=pspwght*1000;
run;



/* Repr�sentation graphique des pourcentages de colonne de la variable SMDFSLV par classe de revenus */

proc gchart data=ess;
goptions reset=all xpixels=1000;
title "R�partition des opinions sur la redistribution des revenus selon le revenu du m�nage";
axis1 label=none value=none;
axis2 label=(angle=90 'Percent');
vbar3d Revenu / discrete subgroup=SMDFSLV freq=pspwght1
	 group=Revenu g100 nozero
	 type=percent
	 inside=percent
	 width=7
	 gaxis=axis1 raxis=axis2 
	 Midpoints = 1 to 4 by 1;
WHERE (SMDFSLV ne 8) and (revenu ne .);
format SMDFSLV SMDFSLV.
Revenu Revenu.;
run;
quit;


/* Repr�sentation graphique des pourcentages de colonne de la variable EARNPEN par classe de revenus */

proc gchart data=ess;
goptions reset=all xpixels=1000;
Title "Avis sur l'attribution des prestations de retraite selon les revenus";
axis1 label=none value=none;
axis2 label=(angle=90 'Percent');
vbar Revenu / discrete subgroup=EARNPEN freq=pspwght1
	 group=Revenu g100 nozero
	 type=percent
	 inside=percent
	 width=7
	 gaxis=axis1 raxis=axis2 
	 Midpoints = 1 to 4 by 1;
WHERE (EARNPEN in (1,2,3)) and (revenu ne .);
format EARNPEN EARNPEN. 
Revenu Revenu.;
run;
quit;


/* Repr�sentation graphique des pourcentages de colonne de la variable Efficacite par classe de revenus */

proc gchart data=ess;
Title "Avis sur l'efficacit� des autorit�s fiscales";
goptions reset=all xpixels=1000;
axis1 label=none value=none;
axis2 label=(angle=90 'Percent');
vbar Revenu / discrete subgroup=Efficacite freq=pspwght1
	 group=Revenu g100 nozero
	 type=percent
	 inside=percent
	 width=7
	 gaxis=axis1 raxis=axis2 
	 Midpoints = 1 to 4 by 1;
WHERE (Efficacite ne .) and (revenu ne .);
format Efficacite Efficacite.
Revenu Revenu.;
run;
quit;


proc gchart data=ess;
goptions reset=all xpixels=1000;
Title "Les aides sociales sont insuffisantes pour les personnes qui sont vraiment dans le besoin";
axis1 label=none value=none;
axis2 label=(angle=90 'Percent');
vbar Revenu / discrete subgroup=INSFBEN freq=pspwght1
	 group=Revenu g100 nozero
	 type=percent
	 inside=percent
	 width=7
	 gaxis=axis1 raxis=axis2 
	 Midpoints = 1 to 4 by 1;
WHERE (INSFBEN not in (7,8,9)) and (revenu ne .);
format
Revenu Revenu.;
run;
quit;



/* Analyse bivari�e (Khi-2) entre revenus et les diff�rentes variables et sauvegarde */

ods RTF file = "C:\M�moire\memoire.rtf";

proc freq data=ess;
tables SMDFSLV*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (TXAUTEF ne 8) and (Revenu ne .);
run;

proc freq data=ess;
tables EARNPEN*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (EARNPEN in (1,2,3) and (Revenu ne .);
run;

proc freq data=ess;
tables INSFBEN*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (INSFBEN not in (7,8,9)) and (Revenu ne .);
run;

proc freq data=ess;
tables TXAUTEF*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (TXAUTEF not in (77,88,99)) and (Revenu ne .);
run;

ods RTF close;



/* Repr�sentation d'un double diagramme en b�tons sur l'opinion sur la fiscalit� selon les revenus */

/* Etape 1: Calcul des fr�quences */
proc freq data=ess;
tables TXEARN*Revenus;
WHERE (TXEARN in (1,2,3)) and (revenus in (1,2));
ODS OUTPUT crossTabFreqs=txearntable;    /* Sauvegarde des r�sultats dans la table chi2 */
weight pspwght;
run;

/* Etape 2: Inversion de signe pour l'une des 2 cat�gories */
DATA txearntable;
  SET txearntable;
if revenus=1 then ColPercent=-ColPercent;
RUN ;

/* Etape 3: Pr�paration des annotations */
data annobars;                                                                                                                          
   length function color $8 text $3;                                                                                                    
   retain xsys ysys '2' when 'a';                                                                                                       
   set txearntable;                                                                                                                               
   function='label';                                                                                                                    
   midpoint=TXEARN;                                                                                                                     
   x=ColPercent;                                                                                                                           
   position='>';                                                                                             
   text=ColPercent;                                                                                                                        
   output;                                                                                                                              
run; 

/* Etape 4: Repr�sentation graphique */
PROC GCHART DATA = txearntable ;
  HBAR TXEARN / DISCRETE NOSTAT SUMVAR = ColPercent TYPE = SUM SUBGROUP = Revenus anotate=annobars;
  WHERE (TXEARN not in (4,7,8,9,.)) and (revenus ne .);
  title "Taxation des contribuables selon leurs revenus";
  format Revenus Revenus. TXEARN TXEARN.;
RUN ; QUIT ;



/* Diagramme en b�tons des moyennes de l'efficacit� des autorit�s par classe de revenu */
proc gchart data=ess;
   hbar Revenu / type=mean
              freqlabel='Revenu'
              meanlabel='Efficacit� des autorit�s fiscales'
              sumvar=TXAUTEF
              errorbar=bars
              noframe
              clm=95
              midpoints=(1 2 3 4)
              coutline=black;
where (TXAUTEF not in (77,88,99)) and (Revenu ne .);
format Revenu Revenu.;
run;
quit;



/* Repr�sentation en Heatmap des Khi-2 de cellule de SMDFSLV  */

/* Etape 1: Calcul des Khi-2 de cellule */
proc freq data=ess;
tables SMDFSLV*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (SMDFSLV ne 8) and (revenu ne .);
ODS OUTPUT crossTabFreqs=chi2;    /* Sauvegarde des r�sultats dans la table chi2 */
weight pspwght;
run;
/* Etape 2 : Repr�sentation graphique */
proc sgplot data=chi2;
title "R�partition des opinions sur la redistribution des revenus selon le revenu du m�nage";
heatmapparm y=Revenu x=SMDFSLV colorresponse=CellChiSquare;
text y=Revenu x=SMDFSLV text=CellChiSquare / textattrs=(size=11pt);
WHERE (SMDFSLV NE 8) and (revenu ne .);
format SMDFSLV SMDFSLV.
Revenu Revenu.;
run;



/* Repr�sentation en Heatmap des Khi-2 de cellule de EARNPEN  */

/* Etape 1: Calcul des Khi-2 de cellule */
proc freq data=ess;
tables EARNPEN*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (EARNPEN in (1,2,3)) and (revenu ne .);
ODS OUTPUT crossTabFreqs=EarnpenHeatmap;    /* Sauvegarde des r�sultats dans la table chi2 */
weight pspwght;
run;
/* Etape 2 : Repr�sentation graphique */
proc sgplot data=EarnpenHeatmap;
title "Avis sur l'attribution des prestations de retraite selon les revenus";
heatmapparm y=EARNPEN x=Revenu colorresponse=CellChiSquare;
text y=EARNPEN x=Revenu text=CellChiSquare;
WHERE (EARNPEN in (1,2,3)) and (revenu ne .);
format EARNPEN EARNPEN.
Revenu Revenu.;
run;

/* Repr�sentation en Donut Chart group�s selon les modalit�s de INSFBEN */
title " R�partition de l'opinion quant � l'insuffisance des prestations sociales pour les plus fragiles selon le niveau de revenu";
proc gchart data=ess;
donut INSFBEN /
subgroup=revenu
donutpct=30
percent = inside
noheading;
WHERE (INSFBEN not in (7,8,9)) and (revenu ne .);
format revenu Revenu.
INSFBEN INSFBEN.;
run;
quit; 

/* Repr�sentation d'un double diagramme circulaire sur l'avis sur l'efficacit� des autorit�s fiscales, par classe de revenu */
goptions reset=all border;	
proc gchart data=ess;
pie Efficacite / detail=Revenu
detail_percent=best
detail_value=none
detail_slice=best
detail_threshold=2
legend
Midpoints = 1 to 10 by 1;
format Revenu Revenu.
Efficacite Efficacite.;
Title "Opinion sur l'efficacit� des autorit�s fiscales, par classe de revenu";
run;
quit;
