// Assignment 5: Graph Analytics — University Course Registration System
// Run against the neo4j database in your newly created DBMS.
// IMPORTANT: Run Task 1 and Task 2 only once. Tasks 3–14 are read-only.

// TASK 1 — Create all 14 nodes (run once)
CREATE
  (:Student {studentId:'S101', name:'Aarav Sharma', semester:5, email:'aarav@univ.edu'}),
  (:Student {studentId:'S102', name:'Priya Das', semester:5, email:'priya@univ.edu'}),
  (:Student {studentId:'S103', name:'Rahul Verma', semester:3, email:'rahul@univ.edu'}),
  (:Student {studentId:'S104', name:'Sneha Roy', semester:3, email:'sneha@univ.edu'}),
  (:Student {studentId:'S105', name:'Arjun Patel', semester:5, email:'arjun@univ.edu'}),
  (:Faculty {facultyId:'F101', name:'Dr. Meera Sen', designation:'Associate Professor', email:'meera@univ.edu', specialization:'Database Systems'}),
  (:Faculty {facultyId:'F102', name:'Dr. Amit Roy', designation:'Assistant Professor', email:'amit@univ.edu', specialization:'Data Analytics'}),
  (:Course {courseCode:'CS301', title:'Graph Analytics', credits:3, level:'Advanced'}),
  (:Course {courseCode:'CS302', title:'Database Management Systems', credits:4, level:'Core'}),
  (:Course {courseCode:'CS303', title:'Data Mining', credits:3, level:'Advanced'}),
  (:Course {courseCode:'CS304', title:'Big Data Analytics', credits:3, level:'Advanced'}),
  (:Course {courseCode:'CS305', title:'NoSQL Databases', credits:2, level:'Core'}),
  (:Department {departmentId:'D101', name:'Computer Science', block:'Block A'}),
  (:Department {departmentId:'D102', name:'Information Technology', block:'Block B'});

// TASK 1 verification
MATCH (n)
RETURN labels(n)[0] AS NodeType, count(n) AS Total
ORDER BY NodeType;

// TASK 2 — Create all 26 relationships (run once, after Task 1)
UNWIND [
  ['S101','CS301'], ['S101','CS302'], ['S101','CS305'],
  ['S102','CS301'], ['S102','CS303'],
  ['S103','CS302'], ['S103','CS304'],
  ['S104','CS303'], ['S104','CS305'],
  ['S105','CS301'], ['S105','CS304']
] AS pair
MATCH (s:Student {studentId: pair[0]})
MATCH (c:Course {courseCode: pair[1]})
CREATE (s)-[:ENROLLED_IN {semesterEnrolled: s.semester, grade:'Not Published'}]->(c)
WITH count(*) AS enrolments
UNWIND [
  ['F101','CS302'], ['F101','CS305'],
  ['F102','CS301'], ['F102','CS303'], ['F102','CS304']
] AS pair
MATCH (f:Faculty {facultyId: pair[0]})
MATCH (c:Course {courseCode: pair[1]})
CREATE (f)-[:TEACHES {academicYear:'2026-27'}]->(c)
WITH enrolments, count(*) AS teachingLinks
UNWIND [
  ['S101','D101'], ['S102','D101'], ['S103','D101'],
  ['S104','D102'], ['S105','D102']
] AS pair
MATCH (s:Student {studentId: pair[0]})
MATCH (d:Department {departmentId: pair[1]})
CREATE (s)-[:BELONGS_TO]->(d)
WITH enrolments, teachingLinks, count(*) AS departmentLinks
UNWIND [
  ['D101','CS302'], ['D101','CS303'], ['D101','CS305'],
  ['D102','CS301'], ['D102','CS304']
] AS pair
MATCH (d:Department {departmentId: pair[0]})
MATCH (c:Course {courseCode: pair[1]})
CREATE (d)-[:OFFERS]->(c)
RETURN enrolments AS EnrolmentsCreated,
       teachingLinks AS TeachingLinksCreated,
       departmentLinks AS DepartmentLinksCreated,
       count(*) AS CourseOfferingLinksCreated;

// TASK 2 verification — expected total: 26
MATCH ()-[r]->()
RETURN type(r) AS RelationshipType, count(r) AS Total
ORDER BY RelationshipType;

// TASK 3 — Display enrolment relationship properties
MATCH ()-[r:ENROLLED_IN]->()
RETURN r.semesterEnrolled AS SemesterEnrolled, r.grade AS Grade;

// TASK 3 — Display teaching relationship properties
MATCH ()-[r:TEACHES]->()
RETURN r.academicYear AS AcademicYear;

// TASK 4 — Display the complete graph (choose Graph view)
MATCH (a)-[r]->(b)
RETURN a, r, b;

// TASK 5 — Count nodes by label
MATCH (n)
RETURN labels(n)[0] AS NodeLabel, count(n) AS TotalNodes
ORDER BY NodeLabel;

// TASK 6 — Relationship types, directions, and counts
MATCH (a)-[r]->(b)
RETURN labels(a) AS SourceLabel,
       type(r) AS RelationshipType,
       labels(b) AS TargetLabel,
       count(r) AS TotalRelationships
ORDER BY RelationshipType;

// TASK 7 — Students in semester 5
MATCH (s:Student)
WHERE s.semester = 5
RETURN s.studentId AS StudentID, s.name AS Name,
       s.semester AS Semester, s.email AS Email;

// TASK 8 — Courses with more than 3 credits
MATCH (c:Course)
WHERE c.credits > 3
RETURN c.courseCode AS CourseCode, c.title AS CourseTitle,
       c.credits AS Credits;

// TASK 9 — Courses taught by Dr. Meera Sen
MATCH (f:Faculty {name:'Dr. Meera Sen'})-[:TEACHES]->(c:Course)
RETURN c.courseCode AS CourseCode, c.title AS CourseTitle;

// TASK 10 — Students enrolled in Graph Analytics
MATCH (s:Student)-[r:ENROLLED_IN]->(c:Course {title:'Graph Analytics'})
RETURN s.name AS StudentName, r.semesterEnrolled AS Semester,
       r.grade AS Grade;

// TASK 11 — Students belonging to Computer Science
MATCH (s:Student)-[:BELONGS_TO]->(d:Department {name:'Computer Science'})
RETURN s.name AS StudentName, d.name AS Department;

// TASK 12 — Courses offered by Information Technology
MATCH (d:Department {name:'Information Technology'})-[:OFFERS]->(c:Course)
RETURN c.courseCode AS CourseCode, c.title AS CourseTitle;

// TASK 13 — NoSQL Databases enrolments
MATCH (s:Student)-[r:ENROLLED_IN]->(c:Course {title:'NoSQL Databases'})
RETURN s.name AS StudentName, r.semesterEnrolled AS Semester,
       r.grade AS Grade;

// TASK 14 — Other courses taken by students enrolled in Graph Analytics
MATCH (s:Student)-[:ENROLLED_IN]->(:Course {title:'Graph Analytics'})
MATCH (s)-[:ENROLLED_IN]->(other:Course)
WHERE other.title <> 'Graph Analytics'
RETURN s.name AS StudentName, collect(other.title) AS OtherCourses;

// FINAL VERIFICATION — expected 14 nodes and 26 relationships
MATCH (n)
WITH count(n) AS TotalNodes
MATCH ()-[r]->()
RETURN TotalNodes, count(r) AS TotalRelationships;
