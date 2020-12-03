/* Copie de la base dans Work */
libname memoire "C:\Mémoire";
data ess;
set memoire.travail;
run;


/* Recodage synthétique des revenus et de l'efficacité des autorités */

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
attrib Revenu label="Revenu total net du ménage";
attrib SMDFSLV label="Pour une société juste, les différences de niveau de vie doivent être faibles";
attrib EARNPEN label="Les personnes à revenus plus élevés ou plus faibles doivent toucher une pension de retraite plus élevée";
attrib Efficacite label="Efficacité des autorités fiscales";
run;


/* Définition de formats clarifiant les modalités des variables */

Proc format;
value SMDFSLV
1 = "Fortement d'accord"
2 = "D'accord"
3 = "Neutre"
4 = "En désaccord"
5 = "Fortement en désaccord";
run;

Proc format;
value EARNPEN
1 = "Revenus élevés"
2 = "Pension égale"
3 = "Revenus faibles";
run;

Proc format;
value Efficacite
1 = "Inefficace"
2 = "Neutre"
3 = "Efficace";
run;

Proc format;
value Revenu /* Version à 4 modalités */
1 = "Faible"
2 = "Moyen-faible"
3 = "Moyen-élevé"
4 = "Elevé";
run;

Proc format;
value Revenus /* Version à 2 modalités */
1 = "Faible"
2 = "Elevé";
run;

Proc format;
value TXEARN
1 = "Payer la même pourcentage des revenus en taxes"
2 = "Les personnes à hauts revenus paient un pourcentage plus élevés en taxes"
3 = "Payer le même montant de taxes";
run;

Proc format;
value INSFBEN
1 = "Fortement d'accord"
2 = "D'accord"
3 = "Neutre"
4 = "En désaccord"
5 = "Fortement en désaccord";
run;


/* Création d'une variable pspwght1 pour contourner la pondération 'freq=' de gchart qui tronque la variable de pondération en un entier */
data ess;
set ess;
pspwght1=pspwght*1000;
run;



/* Représentation graphique des pourcentages de colonne de la variable SMDFSLV par classe de revenus */

proc gchart data=ess;
goptions reset=all xpixels=1000;
title "Répartition des opinions sur la redistribution des revenus selon le revenu du ménage";
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


/* Représentation graphique des pourcentages de colonne de la variable EARNPEN par classe de revenus */

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


/* Représentation graphique des pourcentages de colonne de la variable Efficacite par classe de revenus */

proc gchart data=ess;
Title "Avis sur l'efficacité des autorités fiscales";
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



/* Analyse bivariée (Khi-2) entre revenus et les différentes variables et sauvegarde */

ods RTF file = "C:\Mémoire\memoire.rtf";

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



/* Représentation d'un double diagramme en bâtons sur l'opinion sur la fiscalité selon les revenus */

/* Etape 1: Calcul des fréquences */
proc freq data=ess;
tables TXEARN*Revenus;
WHERE (TXEARN in (1,2,3)) and (revenus in (1,2));
ODS OUTPUT crossTabFreqs=txearntable;    /* Sauvegarde des résultats dans la table chi2 */
weight pspwght;
run;

/* Etape 2: Inversion de signe pour l'une des 2 catégories */
DATA txearntable;
  SET txearntable;
if revenus=1 then ColPercent=-ColPercent;
RUN ;

/* Etape 3: Préparation des annotations */
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

/* Etape 4: Représentation graphique */
PROC GCHART DATA = txearntable ;
  HBAR TXEARN / DISCRETE NOSTAT SUMVAR = ColPercent TYPE = SUM SUBGROUP = Revenus anotate=annobars;
  WHERE (TXEARN not in (4,7,8,9,.)) and (revenus ne .);
  title "Taxation des contribuables selon leurs revenus";
  format Revenus Revenus. TXEARN TXEARN.;
RUN ; QUIT ;



/* Diagramme en bâtons des moyennes de l'efficacité des autorités par classe de revenu */
proc gchart data=ess;
   hbar Revenu / type=mean
              freqlabel='Revenu'
              meanlabel='Efficacité des autorités fiscales'
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



/* Représentation en Heatmap des Khi-2 de cellule de SMDFSLV  */

/* Etape 1: Calcul des Khi-2 de cellule */
proc freq data=ess;
tables SMDFSLV*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (SMDFSLV ne 8) and (revenu ne .);
ODS OUTPUT crossTabFreqs=chi2;    /* Sauvegarde des résultats dans la table chi2 */
weight pspwght;
run;
/* Etape 2 : Représentation graphique */
proc sgplot data=chi2;
title "Répartition des opinions sur la redistribution des revenus selon le revenu du ménage";
heatmapparm y=Revenu x=SMDFSLV colorresponse=CellChiSquare;
text y=Revenu x=SMDFSLV text=CellChiSquare / textattrs=(size=11pt);
WHERE (SMDFSLV NE 8) and (revenu ne .);
format SMDFSLV SMDFSLV.
Revenu Revenu.;
run;



/* Représentation en Heatmap des Khi-2 de cellule de EARNPEN  */

/* Etape 1: Calcul des Khi-2 de cellule */
proc freq data=ess;
tables EARNPEN*Revenu /NOROW NOPERCENT NOFREQ CELLCHI2 CHISQ;
WHERE (EARNPEN in (1,2,3)) and (revenu ne .);
ODS OUTPUT crossTabFreqs=EarnpenHeatmap;    /* Sauvegarde des résultats dans la table chi2 */
weight pspwght;
run;
/* Etape 2 : Représentation graphique */
proc sgplot data=EarnpenHeatmap;
title "Avis sur l'attribution des prestations de retraite selon les revenus";
heatmapparm y=EARNPEN x=Revenu colorresponse=CellChiSquare;
text y=EARNPEN x=Revenu text=CellChiSquare;
WHERE (EARNPEN in (1,2,3)) and (revenu ne .);
format EARNPEN EARNPEN.
Revenu Revenu.;
run;

/* Représentation en Donut Chart groupés selon les modalités de INSFBEN */
title " Répartition de l'opinion quant à l'insuffisance des prestations sociales pour les plus fragiles selon le niveau de revenu";
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

/* Représentation d'un double diagramme circulaire sur l'avis sur l'efficacité des autorités fiscales, par classe de revenu */
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
Title "Opinion sur l'efficacité des autorités fiscales, par classe de revenu";
run;
quit;
