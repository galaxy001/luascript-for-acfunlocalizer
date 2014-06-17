
---[[by lostangel 20130423]]
---[[edit 20140605 for title vid parse]]

require "luascript/lib/lalib"

--[[parse single iqiyi url]]
function getTaskAttribute_iqiyi ( str_url, str_tmpfile , pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '开始解析..');
	end
	local int_acfpv = getACFPV ( str_url );

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

	local str_line = readUntilFromUTF8(file, "<title>");
	--dbgMessage(str_line);

	local _, _, str_Name = string.find(str_line, "<title>(.+)</title>");--"/id_([^\.]+)\./");
	--dbgMessage(str_Name);
	if str_Name==nil then
		return;
	end

	--readin descriptor
	--local str_line = readUntilFromUTF8(file, "\"videoId\"");
	str_line = readUntilFromUTF8(file, "data-player-videoid=\"");
	--dbgMessage(str_line);

	io.close(file);

	local _, _, str_id = string.find(str_line, "data%-player%-videoid=\"([^\"]+)\"");--"/id_([^\.]+)\./");
	--dbgMessage(str_id);
	if str_id==nil then
		return;
	end

	local str_descriptor = str_Name;

	--dbgMessage(str_id);
	--dbgMessage(str_Name);

	local int_realurlnum, tbl_realurls = getRealUrls_iqiyi(str_id, str_tmpfile, pDlg);

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

