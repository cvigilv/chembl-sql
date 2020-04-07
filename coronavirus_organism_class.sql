SELECT td.organism AS grp, COUNT(*) as cnt
FROM activities act
JOIN assays ON assays.assay_id = act.assay_id
JOIN target_dictionary AS td  ON assays.tid = td.tid
JOIN organism_class AS oc ON td.tax_id = oc.tax_id
JOIN compound_structures as cs ON act.molregno = cs.molregno -- datos ligando
WHERE act.standard_flag = "1"
	and td.organism in ("SARS", "CoV", "Coronavirus", "coronavirus")
GROUP BY grp
ORDER BY cnt DESC
