Identify linked pairs in a table across rows

    TWO SOLUTIONS

          1. Simple exaample
          2. More realistic example (on end)

A one liner in R?

StackOverfow SAS
https://tinyurl.com/yc3bbszo
https://stackoverflow.com/questions/51729183/identify-related-value-pairs-in-datasets-with-sas


INPUT
=====

  SD1.HAVE total obs=7

                |  RULES
       FTO      |
                |
     C01:C02    |  C01->C02
     C01:C05    |
     C02:C02    |
     C02:C05    |  C02->C05
     C03:C04    |
     C05:C06    |  C02->C06  => C01->C02->C05->C06
     C11:C12    |


 EXAMPLE OUTPUT
 --------------
    A

    C01:C02:C05:C06
    C03:C04
    C11:C12


PROCESS (R working code - basically a one liner)
=================================================

    * code prior to this just reshapes the input;

    cl <- clusters(graph.data.frame(combspl))$membership[-(1:length(spl))];

    * code after this just athers the result into clusters;

OUTPUT
======

  WORK.WANT total obs=3

   A

   C01:C02:C05:C06
   C03:C04
   C11:C12

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
   input FTO$;
cards4;
C01:C02
C01:C05
C02:C02
C02:C05
C03:C04
C05:C06
C11:C12
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

 proc datasets lib=work kill;
 run;quit;

 %utl_submit_r64('
    library(igraph);
    library(haven);
    data <-read_sas("d:/sd1/have.sas7bdat");
    data<-as.character(data$FTO);
    spl <- strsplit(data,":");
    combspl <- data.frame(
      grp = rep(seq_along(spl),lengths(spl)),
      val = unlist(spl));
    cl <- clusters(graph.data.frame(combspl))$membership[-(1:length(spl))];
    dat <- data.frame(cl);
    dat[,2] <- row.names(dat);
    a <- character(0);
    for (i in 1:max(cl)) {
      a[i] <- paste(paste0(dat[(dat[,1] == i),][,2]), collapse=":");
    };
    a;
    save.image("d:/rda/igraf.Rdata");
 ');

 * if you happen to have IML;
 * convert dataframe males to a SAS dataset;

 proc iml;
   submit / R;
     load('d:/rda/igraf.Rdata');
   endsubmit;
   run importdatasetfromr("work.want","a");
 run;quit;

 Proc print data=want;
 run;quit;

*               _ _     _   _
 _ __ ___  __ _| (_)___| |_(_) ___
| '__/ _ \/ _` | | / __| __| |/ __|
| | |  __/ (_| | | \__ \ |_| | (__
|_|  \___|\__,_|_|_|___/\__|_|\___|

;


/* T3101440 Linked and unlinked clusters of servers that have one or more linkages in common

github
https://tinyurl.com/y8knlugy
https://github.com/rogerjdeangelis/utl_linked_and_unlinked_clusters_of_servers_that_have_one_or_more_linkages_in_common

inspired by
https://goo.gl/QfZlI3
http://stackoverflow.com/questions/42637661/using-r-to-compare-sub-elements-within-a-string-and-summarize-it-so-that-the
and
https://tinyurl.com/y77d456d
https://communities.sas.com/t5/Base-SAS-Programming/Assigining-same-id-by-group-with-additional-rule/m-p/444624

Original Topic: Assigining same id by group with additional rule

   Two solutions: Your simple example and a more general example

   To form linked groups(clusters) you need at least two 'nodes'.
   Single issolated nodes to not add anything in this case.
   I droped the single nodes.



INPUT
=====

 SD1.HAVE total obs=8

  Obs    FTO

   1     A:X
   2     A:Y
   3     B:X
   4     B:Z
   5     C:U
   6     C:V
   7     C:W
   8     D:M


PORCESS (R working code - basically a one liner)
=================================================

    * code prior to this just reshapes the input;

    cl <- clusters(graph.data.frame(combspl))$membership[-(1:length(spl))];

    * code after this just athers the result into clusters;


OUTPUT (more useful form? You can make it long and skinny)
===========================================================

 Up to 40 obs from wantwps total obs=3

Cluster A

  1     A:X:Y:B:Z    (A&B are connected cluster)
  2     C:U:V:W      (C forms a cluster)
  3     D:M          (D is connected to M only)

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have ;
length fto $3;
input fro $ too $;
fto=catx(":",fro,too);
drop fro too;
cards4;
A X
A Y
B X
B Z
C U
C V
C W
D M
;;;;
run;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.1";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
library(igraph);
library(haven);
data <-read_sas("d:/sd1/have.sas7bdat");
data<-as.character(data$FTO);
spl <- strsplit(data,":");
combspl <- data.frame(
  grp = rep(seq_along(spl),lengths(spl)),
  val = unlist(spl)
);
cl <- clusters(graph.data.frame(combspl))$membership[-(1:length(spl))];
dat <- data.frame(cl);
dat[,2] <- row.names(dat);
a <- character(0);
for (i in 1:max(cl)) {
  a[i] <- paste(paste0(dat[(dat[,1] == i),][,2]), collapse=":");
};
a;
endsubmit;
import r=a data=wrk.wantwps;
run;quit;
');

*               _ _     _   _
 _ __ ___  __ _| (_)___| |_(_) ___
| '__/ _ \/ _` | | / __| __| |/ __|
| | |  __/ (_| | | \__ \ |_| | (__
|_|  \___|\__,_|_|_|___/\__|_|\___|

;

SAS/WPS/R: Linked and unlinked clusters of servers that have one or more linkages in common

SAS/WPS/R: Linked and unlinked clusters of servers that have one or more linkages in common

Graph theory (AI)

inspired by
https://goo.gl/QfZlI3
http://stackoverflow.com/questions/42637661/using-r-to-compare-sub-elements-within-a-string-and-summarize-it-so-that-the

HAVE
===

data <- c("A:B:C", "A:B", "E:F:G", "H:I:J", "B:C:D")

WANT
====

I want to convert this to a string of:

c("A:B:C:D", "E:F:G", "H:I:J")

Note A:B:C has common elements A:B and B:C:D but not E:F:G or H:I:J

The idea is that each element inside the string is another string of sub-elements (e.g. A, B, C)
that have been pasted together (with sep=":").
Each element within the string is compared with all other elements to look
for common sub-elements, and elements with common sub-elements are combined.


MORE REALISTIC EXAMPLE (1000 clusters)

HAVE
====

Up to 40 obs from sd1.have total obs=1,002

Obs    STR

  1    B:C:D:E
  2    G:H:I:J:K
  3    L:M:N:O
  4    R:S:T
  5    B:C:D:E
  6    I:J:K      1. links with 12
  7    L:M:N:O
  8    Q:R:S:T
  9    C:D:E
 10    I:J:K
 11    B:C:D:E
 12    F:G:H:I:J  3. I:J:K:F:G:H  linkes with 13 on K
 13    K:L:M:N:O  2. I:J:K:F:G:H:L:M:N:O  (final possibility)
 14    C:D:E
 15    J:K
 16    K:L:M:N:O
 17    B:C:D:E
 18    I:J:K
 19    N:O
 20    R:S:T
 21    A:B:C:D:E
 22    I:J:K
 23    N:O
 24    P:Q:R:S:T
 25    I:J:K
...


 By design

   A:B:C:D:E is an isolated cluster
   P:Q:R:S:T is an isolated cluster

 However there are many other linked clusters

                   <I:J in common)       <K in common>
   I:J:K        I:J-> F:G:H:I:J:K  -> F:G:H:I:J:K:L:M:N:O
   F:G:H:I:J
   K:L:M:N:O


WANT
====

Up to 40 obs from linkages total obs=3

Obs    Linkages

 1     B:C:D:E:A
 2     G:H:I:J:K:L:M:N:O:F
 3     R:S:T:Q:P



WORKING CODE
============

   library(igraph);
   cl <- clusters(graph.data.frame(combspl))$membership[-(1:length(spl))];


CREATE SOME DATA
================

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have(keep=str tridex);
  length str $9;
  retain alpha 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  do i=1 to 300;
    tridex=floor(5*uniform(5673))+1;  * min 1 max 5;
    str=substr(alpha,tridex,6-tridex);
      str=prxchange('s/([a-z]{1})(?=[a-z])/$1:/io',-1,str);
    if length(str)>1 then output;
    tridex=floor(5*uniform(5673))+6;  * min 6 max 10;
    str=substr(alpha,tridex,12-tridex);
      str=prxchange('s/([a-z]{1})(?=[a-z])/$1:/io',-1,str);
    if length(str)>1 then output;
    tridex=floor(5*uniform(5673))+11;   * min 11 max 15;
    str=substr(alpha,tridex,16-tridex);
      str=prxchange('s/([a-z]{1})(?=[a-z])/$1:/io',-1,strip(str));
    if length(str)>1 then output;
    tridex=floor(5*uniform(5673))+16;   * min 16 max 20;
    str=substr(alpha,tridex,21-tridex);
      str=prxchange('s/([a-z]{1})(?=[a-z])/$1:/io',-1,strip(str));
    if length(str)>1 then output;
  end;
run;quit;

FULL SOLUTION
=============


%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.1";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
library(igraph);
library(haven);
data <- c("A:B:C", "A:B", "E:F:G", "H:I:J", "B:C:D");
data <-read_sas("d:/sd1/have.sas7bdat");
data<-as.character(data$STR);
spl <- strsplit(data,":");
combspl <- data.frame(
  grp = rep(seq_along(spl),lengths(spl)),
  val = unlist(spl)
);
cl <- clusters(graph.data.frame(combspl))$membership[-(1:length(spl))];
dat <- data.frame(cl);
dat[,2] <- row.names(dat);
a <- character(0);
for (i in 1:max(cl)) {
  a[i] <- paste(paste0(dat[(dat[,1] == i),][,2]), collapse=":");
};
a;
endsubmit;
import r=a data=wrk.linkages;
run;quit;
');

The WPS System

[1] "B:C:D:E:A"  "G:H:I:J:K:L:M:N:O:F"    "R:S:T:Q:P"

Up to 40 obs from linkages total obs=3

Obs    A

 1     B:C:D:E:A
 2     G:H:I:J:K:L:M:N:O:F
 3     R:S:T:Q:P


