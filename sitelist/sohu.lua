
---[[by lostangel 20130512]]

require "luascript/lib/lalib"

--[[parse single sohu url]]
function getTaskAttribute_sohu ( str_url, str_tmpfile , pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '开始解析..');
	end
	local int_acfpv = getACFPV ( str_url );

	--dbgMessage("in sohu");
	--dbgMessage(str_url);
	-------[[read flv id start]]

	local re = dlFile(str_tmpfile, str_url);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '读取原始页面错误。');
		end
		return;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '已读取原始页面，正在分析...');
		end
	end

	--dbgMessage(pDlg, "dl ok");
	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '读取原始页面错误。');
		end
		return;
	end

	--dbgMessage("before read.");
	--readin descriptor
	local str_line = "";
	str_line = readIntoUntil(file, str_line,"</head>");

	io.close(file);
	--dbgMessage(str_line);

	local _, _, str_id = string.find(str_line, "var vid=\"([^\"]+)\"");--"/id_([^\.]+)\./");
	if str_id==nil then
		return;
	end
	local _, _, str_Name = string.find(str_line, "<title>(.+)</title>");--"/id_([^\.]+)\./");
	if str_id==nil then
		return;
	end
	local str_descriptor = str_Name;

	--dbgMessage("id");
	--dbgMessage(str_id);
	--dbgMessage(str_descriptor);

	local int_realurlnum, tbl_realurls = getRealUrls_sohu(str_id, str_tmpfile, pDlg);

	--str_descriptor = str_Name;


	if pDlg~=nil then
		sShowMessage(pDlg, '完成解析..');
	end

	local tbl_subxmlurls = {};

	local tbl_ta = {};
	tbl_ta["acfpv"] = int_acfpv;
	tbl_ta["descriptor"] = str_descriptor;
	tbl_ta["subxmlurl"] = tbl_subxmlurls;--str_subxmlurl;
	tbl_ta["realurlnum"] = int_realurlnum;
	tbl_ta["realurls"] = tbl_realurls;
	tbl_ta["oriurl"] = str_url;
	--dbgMessage(tbl_realurls["0"]);
	--dbgMessage(tbl_ta["realurls"]["0"]);
	--dbgMessage(string.format("%d videos.", int_realurlnum));

	local tbl_resig = {};
	tbl_resig[string.format("%d",0)] = tbl_ta;
	return tbl_resig;
end

