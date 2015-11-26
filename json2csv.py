#coding:utf-8

import csv
import json
import collections

filename = "test_data"

# フラット化: mapだったらnestされたkeyを連結してdictにする
def flatten(d, parent_key='', sep='.'):
    items = []
    for k, v in d.items():
        new_key = parent_key + sep + k if parent_key else k
        if isinstance(v, collections.MutableMapping):
            items.extend(flatten(v, new_key, sep=sep).items())
        else:
            items.append((new_key, v))
    return dict(items)

json_data = open('data2.json', 'r')
tmp = json.load(json_data)

print(tmp)
tmp = flatten(tmp)
#tmp = json.dumps(tmp, ensure_ascii=False, indent=3, encoding='utf8')
print(tmp)


#read json file.
#json_data = open('data.json', 'r')
#data = json.load(json_data, encoding='utf8')
#json_data.close()
#tmp = flatten(data)
#tmp = json.dumps(tmp, ensure_ascii=False, indent=3, encoding='utf8')
# res = list()

# add header
# tmp = list(data[0]['stat'].items()) + [('key', data[0]['key'])]

#tmp1 = list(data['hits']['hits'][1]['_source'].items())
#tmp2 = list(data['hits']['hits'][1]['_source']['workLocation'].items())
#tmp3 = list(data['hits']['hits'][1]['_source']['workLocation']['address'][0].items())

#tmp = tmp1+tmp2+tmp3
#tmp_dump = json.dumps(tmp1, ensure_ascii=False, indent=3, encoding='utf8')
#print(data)
#tmp_dump = flatten(tmp1)
#print(tmp_dump)
#vals = [x for x in tmp]
#res.append(vals)
#print(res)


#tmp.sort()
#header = [x[0] for x in tmp]
#res.append(header)

# add elements
# res = list(data['hits']['hits'][1]['_source'].items())
# rows = json.dumps(res, ensure_ascii=False, indent=3, encoding='utf8')
#print(res)

'''
for row in res:
    row_list = list(row[1].items())
    dump_list = json.dumps(row_list, ensure_ascii=False, indent=3, encoding='utf8')
    #vals = [x[1] for x in row_list]
    #res.append(vals)
    print(dump_list)
'''

'''
rows = json.dumps(res, ensure_ascii=False, indent=3, encoding='utf8')
print(rows)

# add elements
for row in data:
    row_list = list(row['stat'].items()) + [('key', row['key'])]
    #row_list.sort()
    vals = [x[1] for x in row_list]
    res.append(vals)

# display resulsts
res_dump = json.dumps(res, ensure_ascii=False, indent=2, encoding='utf8')
print(res_dump)

# write a file as csv
with open(filename+'.csv', 'wb') as f:
    mywriter = csv.writer(f, delimiter = ',')
    mywriter.writerows(res)
    f.close()
'''
