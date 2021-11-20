import os
import json

path = './repairResNew/TSEN/afterRepair/'
contractdir = './repairResNew/TSEN/'

fileList = os.listdir(path)
defectList = []
for f in fileList:
	try:
		if f == 'afterRepair':
			continue
		contract_name = f[0:-5]
		print(contract_name)
		vdict = {}
		vdict['name'] = contract_name
		vdict['defect'] = []
		with open(path+f) as fd:
			content = json.loads(fd.read())
			unchecked_line = []
			reentrancy_line = []
			ac_line = []
			greedy_line = []
			strictb_line = []
			for item in content['results']['detectors']:
				if item['check'] == 'locked-ether':
					location = item['elements'][0]
					contractline = location['type'] + ' ' + location['name']
					lineno = 1
					with open(contractdir + contract_name) as contract:
						ccontent = contract.readlines()
						for line in ccontent:
							if contractline in line:
								greedy_line.append(lineno)
								break
							lineno+=1
				elif item['check'] == 'incorrect-equality':
					location  = item['elements'][1]
					if 'this.balance' in location['name']:
						vtype = 'strict_balance'
						strictb_line.append(location['source_mapping']['lines'][0])
				elif item['check'] == 'tx-origin':
					location  = item['elements'][1]
					ac_line.append(location['source_mapping']['lines'][0])
					vtype = 'access_control'
				elif item['check'] == 'unchecked-lowlevel' or item['check'] == 'unchecked-send' or item['check'] == 'unused-return':
					vtype = 'unchecked_low_level_calls'
					location = item['elements'][1]
					# contractline = location['name']
					unchecked_line.append(int(location['source_mapping']['lines'][0]))
				elif item['check'] == 'reentrancy-eth' or item['check'] == 'reentrancy-no-eth':
					vtype = 'reentrancy'
					location = item['elements'][1]
					#  contractline = location['name']
					reentrancy_line.append(int(location['source_mapping']['lines'][0]))
			
			if len(greedy_line) > 0:
				cdict = {}
				cdict['lines'] = greedy_line
				cdict['category'] = 'greedy'
				vdict['defect'].append(cdict)
			
			if len(strictb_line) > 0:
				cdict = {}
				cdict['lines'] = strictb_line
				cdict['category'] = 'strict_balance'
				vdict['defect'].append(cdict)
			
			if len(ac_line) > 0:
				cdict = {}
				cdict['lines'] = ac_line
				cdict['category'] = 'access_control'
				vdict['defect'].append(cdict)
			
			if len(reentrancy_line) > 0:
				cdict = {}
				cdict['lines'] = reentrancy_line
				cdict['category'] = 'reentrancy'
				vdict['defect'].append(cdict)
			
			if len(unchecked_line) > 0:
				cdict = {}
				cdict['lines'] = unchecked_line
				cdict['category'] = 'unchecked_low_level_calls'
				vdict['defect'].append(cdict)
		defectList.append(vdict)
	except:
		defectList.append('failed')
with open('./repairResNew/TSEN/afterRepair/defectList.json', 'w+') as outf:
	outf.write(json.dumps(defectList))
