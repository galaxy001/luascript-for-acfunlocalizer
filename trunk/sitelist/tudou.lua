
---[[by lostangel 20110402]]
---[[edit 20130924 for new parse]]

require "luascript/lib/lalib"

--[[parse single tudou url]]
function getTaskAttribute_tudou ( str_url, str_tmpfile ,str_servername, pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '��ʼ����..');
	end
	local int_acfpv = getACFPV ( str_url );

	-------[[read flv id start]]

	--local _, _, str_id = string.find(str_url, "/programs/view/([^%.]+)/");--"/id_([^\.]+)\./");
	--if str_id==nil then
	--	return;
	--end
	local str_id = nil;
	--[[get descriptor]]
	local re = dlFile(str_tmpfile, str_url);
	if re~=0
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡԭʼҳ�����');
		end
		return;
	else
		if pDlg~=nil then
			sShowMessage(pDlg, '�Ѷ�ȡԭʼҳ�棬���ڷ���...');
		end
	end

	--dbgMessage(pDlg, "dl ok");
	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡԭʼҳ�����');
		end
		return;
	end

	--readin descriptor
	local str_line = readUntil(file, "<title>");
	local str_title_line = readIntoUntil(file, str_line, "</title>");
	local str_title = getMedText(str_title_line, "<title>", "</title>");
	local str_descriptor = str_title;
	--dbgMessage(str_descriptor);

	str_line = readUntil(file, ",itemData={");
	local str_k_line = readIntoUntil(file, str_line, ",segs:");
	local str_iid = getMedText(str_k_line, "iid:", ",");
	if str_iid ~= nil then
		str_id = str_iid;
	end

	--dbgMessage(str_id);

	io.close(file);
	--[[end get descriptor]]

	local int_realurlnum, tbl_realurls = getRealUrls_tudou(str_id, str_tmpfile, pDlg);




	if pDlg~=nil then
		sShowMessage(pDlg, '��ɽ���..');
	end

	local tbl_subxmlurls = {};

	local tbl_ta = {};
	tbl_ta["acfpv"] = int_acfpv;
	tbl_ta["descriptor"] = "tudou"..str_id.." - "..str_descriptor;
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

