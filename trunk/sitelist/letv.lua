
---[[by lostangel 20130714]]

require "luascript/lib/lalib"

--[[parse single letv url]]
function getTaskAttribute_letv ( str_url, str_tmpfile , pDlg)
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

	--dbgMessage("dl ok");
	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '读取原始页面错误。');
		end
		return;
	end

	--readin descriptor
	local str_line = readUntilFromUTF8(file, "<title>");
	--dbgMessage(str_line);
	local str_title_line = readIntoUntilFromUTF8(file, str_line, "</title>");
	local str_title = getMedText(str_title_line, "<title>", "</title>");

	str_line = readUntilFromUTF8(file, "id=\"bofqi\"");
	local str_id_line = readIntoUntilFromUTF8(file, str_line, "</embed>");

	local _, _, str_xmlid = string.find(str_id_line, "bili%-cid=(%d+)");
	local _, _, str_id = string.find(str_id_line, "vid=(%d+)");

	--dbgMessage(str_xmlid);
	--dbgMessage(str_id);

	io.close(file);

	--if str_id ~= nil then
	local int_realurlnum, tbl_realurls = getRealUrls_letv(str_id, str_tmpfile, pDlg);
	--end

	str_descriptor = str_title;


	local tbl_subxmlurls={};
	if str_xmlid~=nil then
		local str_xmlurl = "http://comment.bilibili.tv/".. str_xmlid .. ".xml";
		tbl_subxmlurls["0"] = str_xmlurl;
	end


	if pDlg~=nil then
		sShowMessage(pDlg, '完成解析..');
	end

	--local tbl_subxmlurls = {};

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

