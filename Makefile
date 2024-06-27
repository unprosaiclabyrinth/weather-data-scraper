#variable for all filenames
FILES=report.tmpl image.png report.tex

#URLs for National Weather forecast of different cities:-
#Chicago, IL
URL="https://forecast.weather.gov/MapClick.php?lat=41.8843&lon=-87.6324\#.Y6GmiOxBy3I"
#Phoenix, AZ
#URL="https://forecast.weather.gov/MapClick.php?lat=33.4255&lon=-111.9372\#.Y6GfquxBy3I"
#New York, NY
#URL="https://forecast.weather.gov/MapClick.php?lat=40.7146&lon=-74.0071\#.Y6GmEuxBy3I"
#Boston, MA
#URL="https://forecast.weather.gov/MapClick.php?lat=42.3587&lon=-71.0567\#.Y6GmXexBy3I"
#Los Angeles, CA
#URL="https://forecast.weather.gov/MapClick.php?lat=33.9425&lon=-118.409\#.Y6GnQuxBy3I"

all: report.pdf

#recipe for the report template file (writes template line-by-line)
report.tmpl:
	echo "\\documentclass{article}"                                                                    >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\usepackage{fancyhdr}"                                                                      >> report.tmpl
	echo "\\usepackage{gensymb}"                                                                       >> report.tmpl
	echo "\\usepackage{float}"                                                                         >> report.tmpl
	echo "\\usepackage{graphicx}"                                                                      >> report.tmpl
	echo "\\usepackage{caption}"                                                                       >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\pagestyle{myheadings}"                                                                     >> report.tmpl
	echo "\\\fancyhf{}"                                                                                >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\\title{\$$CITY Weather Forecast}"                                                          >> report.tmpl
	echo "\\\author{National Weather Service}"                                                         >> report.tmpl
	echo "\\\rhead{National Oceanic and Atmospheric Administration}"                                   >> report.tmpl
	echo "\\lhead{7-Day Forecast}"                                                                     >> report.tmpl
	echo "\\\rfoot{forecast.weather.gov}"                                                              >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\\newcommand\\loc{\$$LOC}"                                                                  >> report.tmpl
	echo "\\\newcommand\\\currtempf{\$$CURRTEMPF}"                                                     >> report.tmpl
	echo "\\\newcommand\\\currtempc{\$$CURRTEMPC}"                                                     >> report.tmpl
	echo "\\\newcommand\\\weather{\$$WEATHER}"                                                         >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\\begin{document}"                                                                          >> report.tmpl
	echo "\\maketitle"                                                                                 >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\section*{Current Weather}"                                                                 >> report.tmpl
	echo "The current temperature at {\\loc} is {\\\currtempf}{\\degree}F, {\\\currtempc}{\\degree}C." >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\\begin{figure}[H]"                                                                         >> report.tmpl
	echo "\\\centering"                                                                                >> report.tmpl
	echo "\\includegraphics[width=1in]{image.png}"                                                     >> report.tmpl
	echo "\\\caption*{\\\weather}"                                                                     >> report.tmpl
	echo "\\\end{figure}"                                                                              >> report.tmpl
	echo ""                                                                                            >> report.tmpl
	echo "\\\end{document}"                                                                            >> report.tmpl

#recipe for the (illustration of weather conditions) image
image.png:
	IMG=`curl $(URL) | sed -n 's/<img src="//p' | awk '{print $$1}' | sed 's/^[<.].*//' | tr -d \" | tr -d [:space:]`;\
	curl "https://forecast.weather.gov/$$IMG" -o image.png

#recipe for LaTeX file with current temperature substituted in the template file
report.tex: report.tmpl
	CITY=`curl $(URL) | sed -nE 's/<h2 class="panel-title">(.*)<\/h2>/\1/p' | head -1 | sed -E 's/(.*), .*/\1/'`;\
	LOC=`curl $(URL) | sed -nE 's/<h2 class="panel-title">(.*)<\/h2>/\1/p' | head -1 | sed -E 's/.*, (.*)/\1/'`;\
	WEATHER=`curl $(URL) | sed -n 's/<p class="myforecast-current">//p' | sed 's/<\/p>//' | awk '{print $1}'`;\
	CURRTEMPF=`curl $(URL) | sed -n 's/<p class="myforecast-current-lrg">//p' | sed -n 's/&deg;F<\/p>//p' | tr -d [:space:]`;\
	CURRTEMPC=`curl $(URL) | sed -n 's/<p class="myforecast-current-sm">//p' | sed -n 's/&deg;C<\/p>//p' | tr -d [:space:]`;\
	export CITY LOC WEATHER CURRTEMPF CURRTEMPC;\
	cat report.tmpl | envsubst > report.tex

#recipe for final pdf report
report.pdf: image.png report.tex clean
	pdflatex report.tex
	rm report.aux report.log
	mkdir extras
	mv $(FILES) extras

#recipe for deleting all the above files (in case the Makefile is updated)
clean:
	rm -fr extras report.pdf

.PHONY: clean
