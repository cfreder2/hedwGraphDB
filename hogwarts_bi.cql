//delete all nodes with relationships
match (n)-[r]-(m) delete n,r,m

//delete all non-linked nodes
match (n) delete n;

//create our fake Hogwarts "BI' data
CREATE 
 (hogwarts:School {name : 'Hogwarts', motto : 'Never tickle a sleeping dragon'}),
 (dumbledore:Faculty { name : 'Albus Dumbledore'}),
 (dumbledore)-[:MANAGES]->(hogwarts),
 (snape:Faculty { name : 'Severus Snape'}), 
 (minerva:Faculty { name : 'Minerva McGonagall'}),
 (sprout:Faculty { name : 'Pomona Sprout'}),
 (flitwick:Faculty { name : 'Filius Flitwick'}),
 (slytherin:College { name : 'Slytherin', org_code : '43012'}),
 (gryffindor:College { name : 'Gryffindor', org_code : '29115'}), 
 (hufflepuff:College { name : 'Hufflepuff', org_code : '34021'}), 
 (ravenclaw:College { name : 'Ravenclaw', org_code : '120045'}), 
 (snape)-[:MANAGES]->(slytherin),
 (minerva)-[:MANAGES]->(gryffindor),
 (sprout)-[:MANAGES]->(hufflepuff),
 (flitwick)-[:MANAGES]->(ravenclaw),
 (slytherin)-[:ROLLS_TO]->(hogwarts),
 (gryffindor)-[:ROLLS_TO]->(hogwarts),
 (hufflepuff)-[:ROLLS_TO]->(hogwarts),
 (ravenclaw)-[:ROLLS_TO]->(hogwarts),
 (argus:Staff { name : 'Argus Filch'}),
 (argus)<-[:MANAGES]-(dumbledore),
 (deananalyst:Role { name : 'Dean Analyst'}),
 (generalanalyst:Role { name : 'General Analyst'}),
 (publicanalyst:Role { name : 'Public Analyst'}),
 (snape)-[:HAS_ROLE]->(deananalyst),
 (minerva)-[:HAS_ROLE]->(deananalyst),
 (sprout)-[:HAS_ROLE]->(deananalyst),
 (flitwick)-[:HAS_ROLE]->(deananalyst),
 (argus)-[:HAS_ROLE]->(generalanalyst),
 (dumbledore)-[:HAS_ROLE]->(deananalyst),
 (wrd:Report { name : 'Wizard Retention Dashboard'}),
 (pir:Report { name : 'Witch Headcount Trend'}),
 (cu:Report { name : 'Classroom Utilization'}),
 (active_student:Term { name : 'Active Student', sensitivity : 'public', desc : 'A student admited into hogwards who has not matriculated.'}),
 (college:Term { name : 'College', sensitivity : 'public', desc : 'One of the 4 houses.'}),
 (person_name:Term { name : 'Person Name', sensitivity : 'internal', desc : 'The first and last name of a person'}),
 (student_type:Term { name :'Student Type', sensitivity : 'private', desc : 'Identifies the students type.  Muggles cannot be counted as students'}),
 (room:Term { name : 'Room', sensitivity : 'public', desc : 'A pyhsical space in the interior of a building.'}),
 (room_use:Term { name : 'Room Use', sensitivity : 'public',  desc : 'Describes the rooms primary purpose: classroom, lab, utility, housing'}),
 (lms_rate:Term { name : 'LMS Utilization Rate', sensitivity : 'sensitive', desc : 'A number between 0 and 1 indicating lms system usage'}),
 (lms_rate)-[:USED_IN]->(wrd),
 (college)-[:USED_IN]->(wrd),
 (person_name)-[:USED_IN]->(wrd),
 (active_student)-[:USED_IN]->(wrd),
 (student_type)-[:USED_IN]->(wrd),
 (person_name)-[:USED_IN]->(pir),
 (active_student)-[:USED_IN]->(pir),
 (college)-[:USED_IN]->(pir),
 (room)-[:USED_IN]->(cu),
 (room_use)-[:USED_IN]->(cu),
 (college)-[:USED_IN]->(cu),
 (wrd)<-[:CAN_VIEW]-(deananalyst),
 (cu)<-[:CAN_VIEW]-(generalanalyst),
 (pir)<-[:CAN_VIEW]-(publicanalyst),
 (publicanalyst)<-[:CAN_VIEW]-(generalanalyst),
 (generalanalyst)<-[:CAN_VIEW]-(deananalyst),
 (snape)-[:VIEWED {view_counter:3}]->(wrd),
 (minerva)-[:VIEWED {view_counter:41}]->(wrd),
 (sprout)-[:VIEWED {view_counter:15}]->(wrd),
 (flitwick)-[:VIEWED {view_counter:22}]->(wrd),
 (argus)-[:VIEWED {view_counter:43}]->(cu),
 (flitwick)-[:VIEWED {view_counter:2}]->(pir),
 (minerva)-[:VIEWED {view_counter:8}]->(pir),
 (minerva)-[:VIEWED {view_counter:4}]->(cu)

//show me the whole graph
match (n)-[r]-(m) return n,r

//show me only the hogwarts department structure
match (a)-[:MANAGES]-(b) return a,b

//show me the terms and their relations
match (t:Term)-[r]-(m) return t, r, m 

//show me terms, reports, and roles
match (term)-[:USED_IN]-(report)-[:CAN_VIEW]-(role) return term, report, role 

//What is the list of reports that the Dean Analyst can see?
//Variable length relationships: syntax: -[:TYPE*minHops..maxHops]->. minHops and maxHops are optional
MATCH (r:Role)-[:CAN_VIEW*]-(report:Report) where r.name = "Dean Analyst" return report.name;

//Users who viewed "Witch Headcount Trend" also viewed...
MATCH (report_a)-[:VIEWED]-(user)-[v:VIEWED]-(report_b) where report_a.name = "Witch Headcount Trend" RETURN report_b.name, sum(v.view_counter) as total_views ORDER by total_views desc limit 2

//Impact Analysis: Which reports would be impacted by a change in "active student"
MATCH (term)-[:USED_IN]-(report) where term.name = "Active Student" RETURN report

//Impact Analysis: Which roles would be impacted by a change in "active student"
MATCH (term:Term)-[:USED_IN]->(report),
	  (role:Role)-[:CAN_VIEW*]->(report) RETURN role

//Impact Analysis: Which users might be impacted by a change in "active student"
MATCH (term:Term)-[:USED_IN]->(report),
	  (role:Role)-[:CAN_VIEW*]->(report),
	  (role)<-[:HAS_ROLE]-(user) where term.name = "Active Student" RETURN user

//Impact Analysis: Which users might be impacted by a change in "Student Type"
MATCH (term:Term)-[:USED_IN]->(report),
	  (role:Role)-[:CAN_VIEW*]->(report),
	  (role)<-[:HAS_ROLE]-(user) where term.name = "Student Type" RETURN user

