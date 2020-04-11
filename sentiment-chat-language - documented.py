# This file performs the following functionalities as part of the Data Science. 
# Read the file containing Chats from Gamers.
# Obtain Sentiments from Chats (TextBlob)
# Obtain Subjectivity from Chats.(TextBlob)
# Detect Language from the Chats.(Compact Language Detector (cld))
# Perform Parts of Speech Tagging using TextBlob
# Upload to Database.
import re
from textblob import TextBlob
import sys
import pandas as pd
import MySQLdb
import cld
import json
try:
    #Connect to database
    d=open('config.json')
    jsondf=json.load(d)
    db=MySQLdb.connect('localhost',jsondf['db']['usr'],jsondf['db']['password'],'kabam')
    
    cur=db.cursor()

    #Open the file
    f=open(jsondf['data']['folder']+"/alliance_chat_English.txt","r")
    i=0
    for line in f.readlines():

        i=i+1
        
        if i % 100000 == 0:
               print i
        cols=line.split('\t')
        
        print 'userid:'+cols[0]+'time:'+cols[1]+'Alliance:'+cols[2]+'Text:'+cols[3]
        
        if(re.match(r"\d+-\d+-\d+\s*\d+:\d+:\d+",cols[1])):
            
           text=cols[3].replace("'","")

           if(re.match(r"^\s+..*\s+$",cols[3])):
               cols[3]=cols[3]+'.'
               
           tb=TextBlob(cols[3])

           #Sentiment value Of sentences
           polarity="{0:.5f}".format(tb.sentiment.polarity)

           #Subjectivity
           subjectivity="{0:.5f}".format(tb.sentiment.subjectivity)
           
          #Detect Language using cld
           language=cld.detect(cols[3])[0]               
              
           Nounlength=len(tb.noun_phrases)
           
           #obtain the total number of parts of Speech in the sentence
           
           Tags_dictionary=dict(tb.tags)
           
           inv_dictionary={g:h for h,g in Tags_dictionary.items()}
          
           num_POS=len(inv_dictionary)
           
           #Upload to Database
           
           cur.execute("INSERT INTO alliance_chat_sentiment1(`UserID`,`Time`,`AllianceID`,`Newtext`,`Sentiment`,`Subjectivity`,`Language`,`Noun_phrases`,`num_POS`)values(\'"+cols[0]+"\',\'"+cols[1]+"\',\'"+cols[2]+"\',\'"+text+"\',\'"+str(polarity)+"\',\'"+str(subjectivity)+"\',\'"+str(language)+"\',\'"+str(Nounlength)+"\',\'"+str(num_POS)+"\')")
           
           db.commit()
           
           
except MySQLdb.Error, e:
     if db:
        db.rollback()
     print "error %d: %s" % (e.args[0],e.args[1])
     #sys.exit(1)
     
          
