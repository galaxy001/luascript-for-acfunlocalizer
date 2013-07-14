
---[[by lostangel 20130714]]
---[[edit 20130714 add letv batch mode, and multi-P ]]

require "luascript/lib/lalib"

--[[parse single letv url]]
function getTaskAttribute_letv ( str_url, str_tmpfile , pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '开始解析..');
	end
	local int_acfpv = getACFPV ( str_url );

	local _, _, str_pid = string.find(str_url, "#p(%d+)");
	if str_pid == nil then
		str_pid = "1"
	end

	local pid = tonumber(str_pid);

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
	local str_pname = nil;
	if pid~=1 then
		str_line = readUntilFromUTF8(file, "<div class=\"page_box\">");
		local index = 1;
		local search_index = 1;
		while index <= pid do
			_, search_index, str_id, str_xmlid, str_pname = string.find(str_line, "vid=\"(%d+)\" bili%-cid=\"(%d+)\">([^<>]+)</a>", search_index);
			index = index+1;
		end
	end

	--dbgMessage(str_xmlid);
	--dbgMessage(str_id);

	io.close(file);

	--if str_id ~= nil then
	local int_realurlnum, tbl_realurls = getRealUrls_letv(str_id, str_tmpfile, pDlg);
	--end

	str_descriptor = str_title;
	if str_pname~=nil then
		str_descriptor = str_descriptor .. " - " .. str_pname;
	end


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


--[[parse batch letv url]]
function getTaskAttributeBatch_letv ( str_url, str_tmpfile , pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '开始解析..');
	end
	local int_acfpv = getACFPV ( str_url );

	--local _, _, str_pid = string.find(str_url, "#p(%d+)");
	--if str_pid == nil then
	--	str_pid = "1"
	--end

	--local pid = tonumber(str_pid);

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

	--if pid~=1 then
	local is_multiP = false;
	str_line = readUntilFromUTF8(file, "<div class=\"page_box\">");
	if str_line ~= nil then
		is_multiP = true;
	end

	local tbl_vid = {}
	local tbl_bilicid = {}
	local tbl_pname = {}

	local index = 1;
	local str_pname = "";
	if is_multiP==true then
		local search_index = 1;
		while search_index ~= nil do
			_, search_index, str_id, str_xmlid, str_pname = string.find(str_line, "vid=\"(%d+)\" bili%-cid=\"(%d+)\">([^<>]+)</a>", search_index);
			--dbgMessage(str_id .. "-"..str_xmlid.."-"..str_pname);
			--dbgMessage(tostring(search_index));
			if str_id~=nil and str_xmlid~=nil and str_pname~=nil then
				local str_index = string.format("%d", index);
				tbl_vid[str_index] = str_id;
				tbl_bilicid[str_index] = str_xmlid;
				tbl_pname[str_index] = str_pname;
				index = index+1;
			end

		end
	else
		if str_id~=nil and str_xmlid~=nil and str_pname~=nil then
			local str_index = string.format("%d", index);
			tbl_vid[str_index] = str_id;
			tbl_bilicid[str_index] = str_xmlid;
			tbl_pname[str_index] = str_pname;
			index = index+1;
		end
	end
	--end

	--dbgMessage(str_xmlid);
	--dbgMessage(str_id);

	io.close(file);

	local tbl_re = {};
	local index2= 0;
	for ti = 1, index-1, 1 do
		local str_index = string.format("%d", ti);
		--dbgMessage(str_index);
		sShowMessage(pDlg, string.format("正在解析地址(%d/%d)\"#p%d\",请等待..",ti,index-1,ti));
		for tj = 0, 5, 1 do
			--local str_son_url = urlprefix..tbl_shorturls[str_index];
			--dbgMessage(str_son_url);
			--local tbl_sig = getTaskAttribute_acfun(str_son_url, str_tmpfile, str_servername, nil);
			--dbgMessage(tbl_vid[str_index]);
			--dbgMessage(tbl_pname[str_index]);
			str_id = tbl_vid[str_index];
			str_xmlid = tbl_bilicid[str_index];
			str_descriptor = str_title .. " - " .. tbl_pname[str_index];

			local int_realurlnum, tbl_realurls = getRealUrls_letv(str_id, str_tmpfile, pDlg);
			--end

			local tbl_subxmlurls={};
			if str_xmlid~=nil then
				local str_xmlurl = "http://comment.bilibili.tv/".. str_xmlid .. ".xml";
				tbl_subxmlurls["0"] = str_xmlurl;
			end

			local tbl_ta = {};
			tbl_ta["acfpv"] = int_acfpv;
			tbl_ta["descriptor"] = str_descriptor;
			tbl_ta["subxmlurl"] = tbl_subxmlurls;--str_subxmlurl;
			tbl_ta["realurlnum"] = int_realurlnum;
			tbl_ta["realurls"] = tbl_realurls;
			tbl_ta["oriurl"] = str_url.."#p"..str_index;


			if tbl_ta~=nil then
				local str_index2 = string.format("%d",index2);
				tbl_re[str_index2] = deepcopy(tbl_ta);--dumpmytable(tbl_sig["0"]);--
				index2 = index2+1;
				break;
			else
				--dbgMessage("parse error");
			end
			--dbgMessage(str_descriptor);
		end
	end

	sShowMessage(pDlg, string.format("解析完毕, 共有%d个视频",index2));

	return tbl_re;

	--if str_id ~= nil then

	--dbgMessage(tbl_realurls["0"]);
	--dbgMessage(tbl_ta["realurls"]["0"]);
	--dbgMessage(string.format("%d videos.", int_realurlnum));

	--local tbl_resig = {};
	--tbl_resig[string.format("%d",0)] = tbl_ta;
	--return tbl_resig;
end


