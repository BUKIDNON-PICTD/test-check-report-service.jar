[getCheckbyFund]
SELECT cm.voucherno, cm.checkaccount, ti.checknumber, ti.payee, ti.checkamt FROM checktransmittal t
INNER JOIN checktransmittalitems ti ON ti.transmittalid = t.objid
INNER JOIN checkmain cm ON cm.objid = ti.checkid
WHERE t.transtate = 'CLOSED'
AND cm.checkaccountid LIKE $P{checkaccountid}
AND t.objid = $P{objid}
ORDER BY ti.checknumber ASC

[getCheckReportbyFund]
SELECT erb.accountname, erb.accountid, cm.rjevno, cm.voucherno, erbi.refdate, erbi.refno, cm.payee,
CASE WHEN erbi.refid IN (SELECT cancelleditemid FROM cancelleditems) THEN ca.reason ELSE cm.particulars END AS particulars, 
erbi.debit, erbi.credit, erbi.runbalance FROM estrunningbalance erb
INNER JOIN estrunningbalanceitems erbi ON erbi.parentid = erb.objid
INNER JOIN checkmain cm ON cm.objid = erbi.refid
LEFT JOIN cancelleditems ca ON ca.cancelleditemid = erbi.refid  
WHERE erbi.refid LIKE 'CM%'
AND erbi.refdate BETWEEN $P{datefrom} AND $P{dateto}
AND erb.accountid LIKE $P{accountid}
ORDER BY erbi.lineno

[getCheckReportCashbookbyFund]
SELECT * FROM
(
SELECT erb.accountname, erb.accountid, erbi.refdate, cm.rjevno, cm.voucherno, erbi.refno, cm.payee AS particulars, erbi.debit, erbi.credit, erbi.runbalance, erbi.lineno AS a 
FROM estrunningbalance erb
INNER JOIN estrunningbalanceitems erbi ON erbi.parentid = erb.objid
INNER JOIN checkmain cm ON cm.objid = erbi.refid 
WHERE erbi.refid LIKE 'CM%'
AND erbi.refdate BETWEEN $P{datefrom} AND $P{dateto}
AND erb.accountid LIKE $P{accountid}


UNION ALL

SELECT erb.accountname, erb.accountid, erbi.refdate, a.rjevno, a.voucherno, erbi.refno, a.particulars, erbi.debit, erbi.credit, erbi.runbalance, erbi.lineno AS a   
FROM estrunningbalance erb
INNER JOIN estrunningbalanceitems erbi ON erbi.parentid = erb.objid
INNER JOIN ada a ON a.objid = erbi.refid
WHERE erbi.refid LIKE 'ADA%'
AND erbi.refdate BETWEEN $P{datefrom} AND $P{dateto}
AND erb.accountid LIKE $P{accountid}

UNION ALL

SELECT erb.accountname, erb.accountid, erbi.refdate, t.rjevno, t.voucherno, erbi.refno, t.voucherno AS particulars , erbi.debit, erbi.credit, erbi.runbalance, erbi.lineno AS a  
FROM estrunningbalance erb
INNER JOIN estrunningbalanceitems erbi ON erbi.parentid = erb.objid
INNER JOIN tisoped t ON t.objid = erbi.refid
WHERE erbi.refid LIKE 'DEP%'
AND erbi.refdate BETWEEN $P{datefrom} AND $P{dateto}
AND erb.accountid LIKE $P{accountid}

UNION ALL

SELECT erb.accountname, erb.accountid, erbi.refdate, "rjevno", "voucherno", erbi.refno, erbi.txndate AS particulars, erbi.debit, erbi.credit, erbi.runbalance, erbi.lineno AS a     
FROM estrunningbalance erb
INNER JOIN estrunningbalanceitems erbi ON erbi.parentid = erb.objid
INNER JOIN tisoped t ON t.objid = erbi.refid
WHERE erbi.refid LIKE 'CRM%'
AND erbi.refdate BETWEEN $P{datefrom} AND $P{dateto}
AND erb.accountid LIKE $P{accountid}) xx
ORDER BY xx.a

[getCheckaccount]
SELECT ch.checkaccount, ch.checkaccountid, ct.objid FROM checktransmittal ct 
INNER JOIN checktransmittalitems cti ON cti.transmittalid = ct.objid
INNER JOIN checkmain ch ON ch.objid = cti.checkid 
WHERE ct.objid = $P{objid} 
GROUP BY ch.checkaccount

[getCheckReportaccount]
SELECT * FROM estrunningbalance

[getTransmittalnum]
SELECT * FROM checktransmittal ORDER BY transmittalnum DESC

[getCheckList]
SELECT objid, checkdate, payee, checknumber, checkamt, rjevno, voucherno, checkaccount, checkaccountid
FROM checkmain 
WHERE payee LIKE $P{searchtext}
OR checknumber LIKE $P{searchtext}

[getNonCheckList]
SELECT objid, txndate, people, particulars, controlno, adaamt, rjevno, voucherno, checkaccount, checkaccountid
FROM ada 
WHERE people LIKE $P{searchtext}
OR particulars LIKE $P{searchtext}
OR controlno LIKE $P{searchtext}

[updateVoucherno]
update checkmain set voucherno = $P{voucherno}, rjevno = $P{rjevno}
where objid = $P{objid}

[updateNcVoucherno]
update ada set voucherno = $P{voucherno}, rjevno = $P{rjevno}
where objid = $P{objid}

[getVoucherno]
select * 
from checkmain
where voucherno = $P{voucherno}

[findByRBAcct]
SELECT * FROM checkrunningbalance WHERE accountid=$P{accountid}

[getVerifyAccount]
SELECT * FROM estrunningbalance where accountid = $P{accountid}

[findAmountPerAccount]
SELECT rb.endbalance FROM checkaccount ca
INNER JOIN estrunningbalance rb ON rb.accountid = ca.objid
WHERE ca.objid = $P{objid}