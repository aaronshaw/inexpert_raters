
import os, shutil, time  

topic = 'turk_raters' 
path = '/home/ads/Dropbox/turk_raters/'

#dir_name = "/tmp/turk%s"%int(round(time.time(),0))
#os.mkdir(dir_name)
os.chdir(path)
#os.system('cp -r ./writeup %s'%dir_name)
#os.system('cp -r ./images %s'%dir_name)
#os.system('cp -r ./data %s'%dir_name)
#os.system('cp ~/Dropbox/masterDrop.bib %s'%dir_name)
#os.chdir(dir_name)
os.chdir('writeup')
#os.system("""echo "Sweave('%s.Rnw')" | R --vanilla --quiet"""%topic)
#os.system("sed -f %s.sed %s.tex > temp.tex"%(topic, topic)) 
#os.system('mv %s.tex temp.tex'%topic)
os.system('pdflatex turk_raters')
os.system('bibtex  turk_raters')
os.system('pdflatex  turk_raters')
os.system('pdflatex  turk_raters')
#shutil.copy(' turk_raters.pdf', path + "/writeup/" + topic + ".pdf")
