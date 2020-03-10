# Script to read browse history of Google Chrome.
# Chrome stores history in a Sqlite database called History. 
# The file is in AppData\Local\Google\Chrome\User Data\General.

import sqlite3

path = 'path_to_history'
out_file = 'path_to_report'

conn = sqlite3.connect(path)

curs = conn.cursor()
curs.execute('''SELECT url, title, visit_count, last_visit_time FROM urls''')
urls = curs.fetchall()

out = open(out_file,'w')

for url in urls:
    out.write('\t'.join([str(i) for i in url]))
    out.write('\n')

out.close()