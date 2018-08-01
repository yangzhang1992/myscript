#!/usr/bin/python
# -*- coding: UTF-8 -*-
from xml.etree.ElementTree import fromstring
import os
import sys
import commands
import datetime

import  xdrlib
import xlrd
import  xlwt

reload(sys)
sys.setdefaultencoding('utf8')

def main():
    if len(sys.argv)  < 4:
        print "usage:v2vHistory OldFilename NewerFilename [repo_root]  \n"
        print "OlderFilename is the file name of snapshot of older version\n"
        print "NewerFilename is the file name of snapshot of newer version\n"
        return 1


    OLDER_SNAPSHOT=sys.argv[1]
    NEWER_SNAPSHOT=sys.argv[2]
    repo_root=sys.argv[3]

    print "older snapshot:"+OLDER_SNAPSHOT+"\n"
    print "newer snapshot:"+NEWER_SNAPSHOT+"\n"
    print "number of argv:"+str(len(sys.argv)) +"\n"


    if len(sys.argv)  > 3:
        ROOTPATH=repo_root
    else:
        ROOTPATH=os.path.abspath(sys.argv[0])
        ROOTPATH=os.path.split(ROOTPATH)[0]
        print "repo root path:"+ROOTPATH

    with open(OLDER_SNAPSHOT) as olderfile:
        older_root = fromstring(olderfile.read())

    with open(NEWER_SNAPSHOT) as newerfile:
        newer_root = fromstring(newerfile.read())

	excel_file = xlwt.Workbook()
    table = excel_file.add_sheet('version differnce',cell_overwrite_ok=True)

    font0 = xlwt.Font()
    font0.name = 'Times New Roman'
    font0.colour_index = 2
    font0.bold = True
    style0 = xlwt.XFStyle()
    style0=xlwt.easyxf('align: wrap on')

    style0.font = font0

    style1 = xlwt.easyxf('align: wrap on')


    table.write(0,0,unicode('old version: '+OLDER_SNAPSHOT),style0)
    table.write(0,1,unicode('new version: '+NEWER_SNAPSHOT),style0)
    table.write(1,0,unicode('repo name'),style0)
    table.write(1,1,unicode('repo path'),style0)
    table.write(1,2,unicode('author'),style0)
    table.write(1,3,unicode('log'),style0)
    table.write(1,4,unicode('check status'),style0)

    table.col(0).width = 13332
    table.col(1).width = 13332
    table.col(2).width = 3333
    table.col(3).width = 33330
    table.col(4).width = 3333

    line_number=2

    excel_file.save('ReleaseNotes.xls')
    for child in newer_root.getchildren():
        if child.tag == 'project':
            print "name:"+child.attrib['name']+"\n"
            print "path:"+child.attrib['name']+"\n"
            prj_name=child.attrib['name']
            #prj_path=child.attrib['path']
            #if prj_path is None:
            #if not child.attrib['path']:
            #if child.hasAttrib("name"):
            if child.attrib.has_key("path"):
                prj_path=child.attrib['path']
                print "path==========:"+prj_path+"\n"
            else:
                prj_path=child.attrib['name']
                print "name==========:"+prj_path+"\n"

            print "newer revision:"+child.attrib['revision']+"\n"
            newer_prj_revision=child.attrib['revision']

            if child.attrib.has_key("path"):
                FIND_PATTERN='./project[@path='+"'"+prj_path+"'"+']'
            else:
                FIND_PATTERN='./project[@name='+"'"+prj_path+"'"+']'

            #FIND_PATTERN='./project[@name='+"'"+prj_path+"'"+']'
            older_root.find("./project[@name='device/sample']")

            print "FIND_PATTERN:"+FIND_PATTERN
            old_match=older_root.find(FIND_PATTERN)
            if old_match is None:
                print "old_match not found"
                COMMAND="git log "+newer_prj_revision +" --oneline"+" | wc -l"
                os.chdir(ROOTPATH+"/"+prj_path)
                commit_count=os.popen(COMMAND).read()
                print "commit count:"+commit_count
                count=0
                while count < int(commit_count):
                     COMMAND="git log "+newer_prj_revision+"~"+str(count+1)+".."+newer_prj_revision+"~"+str(count)
                     output=os.popen(COMMAND).read()
                     table.write(line_number,0,prj_name.decode('utf-8'),style1)
                     table.write(line_number,1,prj_path.decode('utf-8'),style1)
                     table.write(line_number,3,output.decode('utf-8'),style1)


                     excel_file.save('ReleaseNote.xls')
                     print "command:"+COMMAND+"\n"
                     print "output:{}\n".format(output)
                     print "output length:"+str(len(output))
                     COMMAND="git log "+newer_prj_revision+"~"+str(count+1)+".."+newer_prj_revision+"~"+str(count)+unicode(" | grep '作者'")
                     output=os.popen(COMMAND).read()
                     print "command:"+COMMAND+"\n"
                     print "output:{}\n".format(output)
                     if  output:
                         table.write(line_number,2,output.decode('utf-8'),style1)
                     else:
                         COMMAND="git log "+newer_prj_revision+"~"+str(count+1)+".."+newer_prj_revision+"~"+str(count)+" | grep 'Author'"
                         output=os.popen(COMMAND).read()
                         table.write(line_number,2,unicode(output),style1)
                         print "command:"+COMMAND+"\n"
                        # print "output:{}\n".format(output)

                     excel_file.save('ReleaseNote.xls')
                     line_number = line_number+1
                     count = count+1
                os.chdir(ROOTPATH)
                continue


            old_prj_revision=old_match.attrib['revision']
            print "older revision:"+old_prj_revision

            if old_prj_revision != newer_prj_revision:
                COMMAND="git log "+old_prj_revision+".."+newer_prj_revision +" --oneline"+" | wc -l"
                os.chdir(ROOTPATH+"/"+prj_path)
                commit_count=os.popen(COMMAND).read()
                print "commit count:"+commit_count
                count=0
                while count < int(commit_count):
                     COMMAND="git log "+newer_prj_revision+"~"+str(count+1)+".."+newer_prj_revision+"~"+str(count)
                     output=os.popen(COMMAND).read()
                     table.write(line_number,0,prj_name.decode('utf-8'),style1)
                     table.write(line_number,1,prj_path.decode('utf-8'),style1)
                     table.write(line_number,3,output.decode('utf-8'),style1)


                     excel_file.save('ReleaseNote.xls')
                     print "command:"+COMMAND+"\n"
                     #print "output:{}\n".format(output)
                     print "output length:"+str(len(output))

                     COMMAND="git log "+newer_prj_revision+"~"+str(count+1)+".."+newer_prj_revision+"~"+str(count)+unicode(" | grep '作者'")
                     output=os.popen(COMMAND).read()
                     print "command:"+COMMAND+"\n"
                     print "output:{}\n".format(output)
                     if  output:
                         table.write(line_number,2,unicode(output),style1)
                     else:
                         COMMAND="git log "+newer_prj_revision+"~"+str(count+1)+".."+newer_prj_revision+"~"+str(count)+" | grep 'Author'"
                         output=os.popen(COMMAND).read()
                         table.write(line_number,2,unicode(output),style1)
                         print "command:"+COMMAND+"\n"
                      #   print "output:{}\n".format(output)

                     excel_file.save('ReleaseNote.xls')
                     line_number = line_number+1
                     count = count+1
                os.chdir(ROOTPATH)

    excel_file.save('ReleaseNote.xls')

if __name__ == '__main__': # Only when run
    main()

