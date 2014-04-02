
---[[by lostangel 20100528]]
---[[edit 20100827]]
---[[edit 20110117 adding parsing youku flv]]
---[[edit 20110222 editing xmlserver]]
---[[edit 20110402 editing xmllock and return struct]]
---[[edit 20110415 editing for seperate subid/ and acplayert.swf]]
---[[edit 20110507 for http://www.acfun.cn/html/zj/20100205/75086.html another mid= in wrong location ]]
---[[edit 20110527 for acfun_xml_servername value]]
---[[edit 20110705 for acfun.tv/v/acxxxxx]]
---[[edit 20110710 for acfun.tv/plus/view.php?aid=xxx&pageno=xxx]]
---[[edit 20110809 for cid= commentid equal to mid= messageid]]
---[[edit 20111102 for acfun new flashvar embed id]]
---[[edit 20111106 for new acfun sub]]
---[[edit 20120408 for new acfun comment server]]
---[[edit 20120413 for new acfun comment server]]
---[[edit 20120416 for new acfun ui]]
---[[edit 20120421 for new acfun ui]]
---[[edit 20120421 for acfun tudou video]]
---[[edit 20120423 for acfun new ui]]
---[[edit 20120503 for acfun new ui]]
---[[edit 20120609 for acfun batch]]
---[[edit 20120817 for acfun delete old comment server]]
---[[edit 20120924 for acfun new ui]]
---[[edit 20120925 for acfun Video tag (video)]]
---[[edit 20121127 for acfun video <embed> parse ]]
---[[edit 20130117 for acfun batch]]
---[[edit 20131002 for acfun.com no response]]
---[[edit 20131109 for acfun pps]]
---[[edit 20131225 for acfun new tag]]
---[[edit 20131230 for acfun new ui]]
---[[edit 20140122 for acfun iqiyi source video.]]
---[[edit 20140402 for acfun new ui]]

require "luascript/lib/lalib"

acfun_xml_servername = 'www.acfun.tv'; --'124.228.254.234';--'www.sjfan.com.cn';
acfun_comment_servername = 'comment.acfun.tv';--'122.224.11.162';--

--[[parse single acfun url]]
function getTaskAttribute_acfun ( str_url, str_tmpfile ,str_servername, pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '��ʼ����..');
	end
	local int_acfpv = getACFPV ( str_url, str_servername );

	-------[[read flv id start]]

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

	--dbgMessage("dl ok");
	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡԭʼҳ�����');
		end
		return;
	end

	local int_foreignlinksite = fls["realurl"];

	local str_id = "";

	local str_aid = "";

	local str_subid = str_id;

	local str_descriptor = "";

	local str_tmp_vd = "";

	local str_title = "";

	--isFramework?
	local isFramework = 0;
	local str_line = readUntilFromUTF8(file, "<html");
	local str_meta_line = str_line;
	if string.find(str_meta_line, "</title>", 1, true)==nil then
		str_meta_line = readIntoUntilFromUTF8(file, str_line, "<!--title-->");
	end
	--dbgMessage(str_meta_line);
	--dbgMessage(string.find(str_meta_line, "<!--meta-->",1 ,true));
	if string.find(str_meta_line, "<!--meta-->", 1, true)~=nil then
		--is Framework
		isFramework = 1;
		--dbgMessage("framework");

		--readin descriptor
		str_line = readUntilFromUTF8(file, "<title>");
		--dbgMessage(str_line);
		local str_title_line = readIntoUntilFromUTF8(file, str_line, "</title>");
		str_title = getMedText(str_title_line, "<title>", "</title>");

		--dbgMessage(str_title);

		str_line = readUntilFromUTF8(file, "system.aid");
		local transid = getMedText(str_line, "system.aid = ", ";");
		--dbgMessage(transid);

		local tbl_id_titles = getAcVideo_Vid_Cid_Titles(transid, str_tmpfile .. ".tmpacapi", pDlg);

		--dbgMessage(tbl_id_titles["1"]["desp"]);
		--dbgMessage(str_url);
		local _, _, str_vindex = string.find(str_url, "ep=(%d+)");

		if str_vindex==nil then
			str_vindex = "1";
		end
		--dbgMessage(str_vindex);

		str_id = tbl_id_titles[str_vindex]["vid"];
		str_aid = tbl_id_titles[str_vindex]["cid"];
		str_subid = tbl_id_titles[str_vindex]["vid"];
		int_foreignlinksite = fls["iqiyi"];
		str_tmp_vd = tbl_id_titles[str_vindex]["desp"];

	else

		--readin descriptor
		str_line = str_meta_line;
		if string.find(str_line, "<title>", 1,true)==nil then
			str_line = readUntilFromUTF8(file, "<title>");
		end
		--dbgMessage(str_line);
		local str_title_line = str_line;
		if string.find(str_title_line, "</title>", 1, true)==nil then
			str_title_line = readIntoUntilFromUTF8(file, str_line, "</title>");
		end
		str_title = getMedText(str_title_line, "<title>", "</title>");

		--dbgMessage(str_title);
		--readin vice descriptor
		--readUntil(file, "��ҳ</a>");
		--readUntilFromUTF8(file, "</div><!--Tool -->");
		--readUntilFromUTF8(file, "</div><!--Title -->");
		--readUntilFromUTF8(file ,"<div id=\"area-pager\" class=\"area-pager\">");
		readUntilFromUTF8(file , "<div id=\"area-part-view\"");
		str_line = "";

		--while str_line~=nil and string.find(str_line, "</tr>")==nil
		while str_line~=nil and string.find(str_line, "</div>")==nil
		--while str_line~=nil and string.find(str_line, "����")==nil
		do
			str_line = file:read("*l");
			str_line = utf8_to_lua(str_line);
			--dbgMessage(str_line);
			--if str_line~=nil and string.find(str_line, "<option value='")~=nil
			--if str_line~=nil and string.find(str_line, "<a class=\"")~=nil
			--local t_t = string.find(str_line, "<a data-vid=\"", 1, true);
			--dbgMessage(string.format("%d", t_t));

			if str_line~=nil and string.find(str_line, "<a data-vid=\"", 1, true)~=nil
			then
				--dbgMessage("pager article");
				--if str_tmp_vd=="" or string.find(str_line, "selected>")~=nil
				--if str_tmp_vd=="" or string.find(str_line, "pager active")~=nil
				if str_tmp_vd=="" or string.find(str_line, "success active", 1, true)~=nil
				then
					--dbgMessage("pager active");
					--str_tmp_vd = getMedText(str_line, ">", "</option>");
					str_tmp_vd = getMedText(str_line, "/i>", "</a>");

					local str_acinternalID = getMedText(str_line, "data-vid=\"", "\"");

					--dbgMessage(str_acinternalID);

					int_foreignlinksite, str_id, str_subid = getAcVideo_CommentID(str_acinternalID, str_tmpfile..".tmpac", pDlg);

				end
			end
		end

	end
	--save descriptor

	if str_tmp_vd ~= ""
	then
		str_descriptor = str_title.."-"..str_tmp_vd;
	else
		str_descriptor = str_title;
	end

	--dbgMessage(str_title);
	--dbgMessage(str_tmp_vd);
	--dbgMessage(str_descriptor);

--~ 	--find embed flash
--~ 	--str_line = readUntilFromUTF8(file, "<embed ");
--~ 	str_line = readUntilFromUTF8(file, "<div id=\"area-player\"");
--~ 	local str_embed = readIntoUntilFromUTF8(file, str_line, "<script>");--edit 20121127 </div>");--"</td>");--"</embed>");
--~ 	print(str_embed);
--~ 	--dbgMessage(str_embed);
--~ 	if str_embed==nil then
--~ 		if pDlg~=nil then
--~ 			sShowMessage(pDlg, "û���ҵ�Ƕ���flash������");
--~ 		end
--~ 		io.close(file);
--~ 		return;
--~ 	end

--~ 	local b_isArtemis = 0;
--~ 	if string.find(str_embed, "Artemis",1,true)~=nil or string.find(str_embed, "[Video]",1,true)~=nil  or string.find(str_embed, "[video]",1,true)~=nil then
--~ 		b_isArtemis = 1;
--~ 		--dbgMessage("artemis");
--~ 	end

--~ 	local int_foreignlinksite = fls["realurl"];
--~ 	local str_id = "";
--~ 	local str_subid = str_id;
--~ 	if b_isArtemis==0 then
--~ 		--dbgMessage("old");
--~ 		--read foreign file
--~ 		local str_notsinaurl = "";
--~ 		if string.find(str_embed, "flashvars=\"file=", 1, true)~=nil
--~ 		then
--~ 			str_notsinaurl = getMedText2end(str_embed, "flashvars=\"file=", "\"", "&amp;");
--~ 		elseif string.find(str_embed, "playerf.swf?file=")~=nil
--~ 		then
--~ 			str_notsinaurl = getMedText2end(str_embed, "playerf.swf?file=", "\"", "&amp;");
--~ 		elseif string.find(str_embed, "file=")~=nil
--~ 		then
--~ 			str_notsinaurl = getMedText2end(str_embed, "file=", "\"", "&amp;");
--~ 		end

--~ 		--certain foreign sitelink
--~ 		if str_notsinaurl=="" then
--~ 			if string.find(str_embed, "type2=qq", 1,true)~=nil then
--~ 				int_foreignlinksite = fls["qq"];
--~ 			elseif string.find(str_embed, "type2=youku", 1,true)~=nil then
--~ 				int_foreignlinksite = fls["youku"];
--~ 			elseif string.find(str_embed, "type2=tudou", 1,true)~=nil then
--~ 				int_foreignlinksite = fls["tudou"];
--~ 			else
--~ 				int_foreignlinksite = fls["sina"];
--~ 			end
--~ 		end

--~ 		--certain acfpv
--~ 		if string.find(str_embed, "flvplayer/acplayer.swf")~=nil or string.find(str_embed, "flvplayer/acplayert.swf")~=nil
--~ 		then
--~ 			int_acfpv = 0; -- ACFPV_ORI
--~ 		end

--~ 		--read id

--~ 		if string.find(str_embed, "flashvars=\"id=")~=nil
--~ 		then
--~ 			str_id = getMedText2end(str_embed, "flashvars=\"id=", "\"", "&amp;");
--~ 		elseif string.find(str_embed, "flashvars=\"avid=")~=nil
--~ 		then
--~ 			str_id = getMedText2end(str_embed, "flashvars=\"avid=", "\"", "&amp;");
--~ 		elseif string.find(str_embed, "?id=")~=nil
--~ 		then
--~ 			str_id = getMedText2end(str_embed, "?id=", "\"", "&amp;");
--~ 		elseif string.find(str_embed, "id=")~=nil
--~ 		then
--~ 			str_embed_tmp = getAfterText(str_embed, "flashvars=");
--~ 			if str_embed_tmp==nil
--~ 			then
--~ 				str_embed_tmp = getAfterText(str_embed, "src=");
--~ 			end
--~ 			str_id = getMedText2end(str_embed_tmp, "id=", "\"", "&amp;");
--~ 		--elseif string.find(str_embed, "[Video]")~=nil
--~ 		--then
--~ 		--	str_id = getMedText(str_embed, "[Video]", "[/Video]");
--~ 		--	int_foreignlinksite,str_id, str_subid, = getAcVideo_CommentID(str_id,
--~ 		--	str_subid="";--not com
--~ 		--	str_id="";--
--~ 		end

--~ 		--dbgMessage(str_id);
--~ 		--if there is a seperate subid
--~ 		if string.find(str_embed, "mid=")~= nil then
--~ 			str_subid = getMedText2end(str_embed, "mid=", "\"", "&amp;");
--~ 		elseif string.find(str_embed, "cid=")~= nil then
--~ 			str_subid = getMedText2end(str_embed, "cid=", "\"", "&amp;");
--~ 		end
--~ 	elseif b_isArtemis==1 then
--~ 		int_acfpv = 1; -- ACFPV_NEW
--~ 		local str_acinternalID = getMedText(str_embed, "{'id':'", "','system'");
--~ 		if str_acinternalID == nil then
--~ 			str_acinternalID = getMedText(str_embed, "[Video]", "[/Video]");
--~ 		end
--~ 		if str_acinternalID == nil then
--~ 			str_acinternalID = getMedText(str_embed, "[video]", "[/video]");
--~ 		end
--~ 		--dbgMessage(str_acinternalID);

--~ 		int_foreignlinksite, str_id, str_subid = getAcVideo_CommentID(str_acinternalID, str_tmpfile..".tmpac", pDlg);

--~ 		--dbgMessage(str_id);
--~ 		--dbgMessage(str_subid);
--~ 	end

	--dbgMessage(str_id);

	--read id ok.close file
	io.close(file);

	if str_id == ""
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '����FLV ID����');
		end
		return;
	end
	------------------------------------------------------------[[read flv id end]]


	--dbgMessage(str_id);

	if str_subid=="" then
		str_subid = str_id;
	end
	--define subxmlurl
	local str_subxmlurl = "";
	local str_subxmlurl_lock = "";
	local str_subxmlurl_super = "";
	if int_acfpv==1 --ACFPV_NEW
	then
		str_subxmlurl = "http://"..acfun_xml_servername.."/newflvplayer/xmldata/"..str_subid.."/comment_on.xml?r=1";
		str_subxmlurl_lock = "http://"..acfun_xml_servername.."/newflvplayer/xmldata/"..str_subid.."/comment_lock.xml?r=1";
		str_subxmlurl_super = "http://"..acfun_xml_servername.."/newflvplayer/xmldata/"..str_subid.."/comment_super.xml";
		str_subxmlurl_20111106 = "http://"..acfun_comment_servername.."/".. str_subid ..".json?clientID=0.9264421034604311";
		str_subxmlurl_lock_20111106 = "http://"..acfun_comment_servername.."/".. str_subid .."_lock.json?clientID=0.4721592585556209";
		--str_subxmlurl_20111106 = "http://"..acfun_comment_servername.."/".. str_subid ..".json";
		--str_subxmlurl_lock_20111106 = "http://"..acfun_comment_servername.."/".. str_subid .."_lock.json";
	else --ACFPV_ORI
		str_subxmlurl = "http://"..acfun_xml_servername.."/flvplayer/xmldata/"..str_subid.."/comment_on.xml?a=1";
	end

	--realurls
	local int_realurlnum = 0;
	local tbl_realurls = {};
	--if str_notsinaurl=="" -- is sina flv
	if int_foreignlinksite == fls["sina"]
	then
		--fetch dynamic url
		int_realurlnum, tbl_readurls = getRealUrls(str_id, str_tmpfile, pDlg);
	elseif int_foreignlinksite == fls["qq"]
	then
		int_realurlnum, tbl_readurls = getRealUrls_QQ(str_id, str_tmpfile, pDlg);
	elseif int_foreignlinksite == fls["youku"]
	then
		int_realurlnum, tbl_readurls = getRealUrls_youku(str_id, str_tmpfile, pDlg);
	elseif int_foreignlinksite == fls["tudou"]
	then
		int_realurlnum, tbl_readurls = getRealUrls_tudou(str_id, str_tmpfile, pdlg);
	elseif int_foreignlinksite == fls["pps"]
	then
		int_realurlnum, tbl_readurls = getRealUrls_pps(str_id, str_tmpfile, pdlg);
	elseif int_foreignlinksite == fls["iqiyi"]
	then
		int_realurlnum, tbl_readurls = getRealUrls_iqiyi(str_id, str_tmpfile, pDlg);
	else
		int_realurlnum = 1;
		tbl_readurls = {};
		tbl_readurls[string.format("%d",0)] = str_notsinaurl;
	end

	if pDlg~=nil then
		sShowMessage(pDlg, '��ɽ���..');
	end

	local tbl_subxmlurls={};
	tbl_subxmlurls["0"] = str_subxmlurl;
	if str_subxmlurl_lock ~= "" then
		tbl_subxmlurls["1"] = str_subxmlurl_lock;
		tbl_subxmlurls["2"] = str_subxmlurl_super;
		tbl_subxmlurls["3"] = str_subxmlurl_20111106;
		tbl_subxmlurls["4"] = str_subxmlurl_lock_20111106;
	end

	local _, _, str_acfid = string.find(str_url, "/([%d_]+).html");
	local str_acfid_subfix = nil;
	if str_acfid == nil
	then
		_,_,str_acfid = string.find(str_url, "/[a]?[c]?([%d_]+)/?");
		_,_, str_acfid_subfix = string.find(str_url, "/index([%d_]*).html");
		if str_acfid_subfix ~= nil then
			str_acfid = str_acfid .. str_acfid_subfix;
		end
	end
	--for http://acfun.tv/plus/view.php?aid=xxxxxxx
	if str_acfid == nil
	then
		_,_,str_acfid = string.find(str_url, "/view.php%?aid=([%d_]+)");
		_,_,str_acfid_subfix = string.find(str_url, "pageno=([%d]+)");
		if str_acfid_subfix ~= nil then
			str_acfid = str_acfid .. str_acfid_subfix;
		end
	end

	--for http://hengyang.acfun.tv/sp/aqgy/?ep=2
	if str_acfid == nil
	then
		_, _, str_acfid_subfix = string.find(str_url, "ep=(%d+)");
		if str_acfid_subfix ~= nil then
			str_acfid = str_aid .. str_acfid_subfix;
		else
			str_acfid = str_aid;
		end
	end

	local tbl_ta = {};
	tbl_ta["acfpv"] = int_acfpv;
	tbl_ta["descriptor"] = "ac"..str_acfid.." - "..str_descriptor;
	--tbl_ta["subxmlurl"] = str_subxmlurl;
	tbl_ta["subxmlurl"] = tbl_subxmlurls;
	tbl_ta["realurlnum"] = int_realurlnum;
	tbl_ta["realurls"] = tbl_readurls;
	tbl_ta["oriurl"] = str_url;

	local tbl_resig = {};
	tbl_resig[string.format("%d",0)] = tbl_ta;
	return tbl_resig;
end

--[[parse every video in acfun url]]
function getTaskAttributeBatch_acfun ( str_url, str_tmpfile ,str_servername, pDlg)
	if pDlg~=nil then
		sShowMessage(pDlg, '��ʼ����..');
	end

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

	local file = io.open(str_tmpfile, "r");
	if file==nil
	then
		if pDlg~=nil then
			sShowMessage(pDlg, '��ȡԭʼҳ�����');
		end
		return;
	end

	--readin descriptor
	local str_line = readUntilFromUTF8(file, "<title>");
	local str_title_line = readIntoUntilFromUTF8(file, str_line, "</title>");
	local str_title = getMedText(str_title_line, "<title>", "</title>");

	--readin vice descriptor
	--readUntil(file, "��ҳ</a>");
	--readUntilFromUTF8(file, "</div><!--Tool -->");
	--readUntilFromUTF8(file, "</div><!--Title -->");
	--readUntilFromUTF8(file ,"<div id=\"area-pager\" class=\"area-pager\">");
	readUntilFromUTF8(file , "<div id=\"area-part-view\"");

	str_line = "";
	local tbl_descriptors = {};
	local tbl_shorturls = {};
	local index = 0;
	while str_line~=nil and string.find(str_line, "</div>")==nil--"</tr>")==nil
	--while str_line~=nil and string.find(str_line, "����")==nil
	do
		str_line = file:read("*l");
		str_line = utf8_to_lua(str_line);
		--dbgMessage(str_line);
		--if str_line~=nil and string.find(str_line, "<option value='")~=nil
		--if str_line~=nil and string.find(str_line, "<a class")~=nil
		if str_line~=nil and string.find(str_line, "<a data-vid=\"", 1, true)~=nil
		then
			--dbgMessage("page article");
			local str_tmp_vd = getMedText(str_line, "/i>", "</a>");
			if str_tmp_vd == nil then
				str_tmp_vd = getMedText(str_line, "\">", "</a>");
			end
			local str_tmp_url = getMedText(str_line, "href=\"", "\"");
			local str_index = string.format("%d", index);
			tbl_descriptors[str_index] = --[[str_title.."-"..]]str_tmp_vd;
			--dbgMessage(str_tmp_url);
			tbl_shorturls[str_index] = str_tmp_url;
			index = index+1;
		end
	end

	--readin pairs ok. close file
	io.close(file);

	if index==0 then
		local str_index = string.format("%d", index);
		tbl_descriptors[str_index] = str_title;
		local bg_t,ed_t = string.find(string.reverse(str_url),"/",1,true);
		ed_t = string.len(str_url)+1-ed_t;
		--tbl_shorturls[str_index] = string.sub(str_url, ed_t+1) ;
		tbl_shorturls[str_index] = "/v/"..string.sub(str_url, ed_t+1) ;
		index = index+1;
	end

	--dbgMessage(string.format("%d", index));

	--------[[parse every url in pairs]]

	--local bg,ed = string.find(string.reverse(str_url),"/",1,true);
	--ed = string.len(str_url)+1-ed;
	--local urlprefix = string.sub(str_url, 1, ed);
	--local urlprefix = "http://www.acfun.tv"
	local urlprefix = "http://www.acfun.com"

	local tbl_re = {};
	local index2= 0;
	for ti = 0, index-1, 1 do
		local str_index = string.format("%d", ti);
		sShowMessage(pDlg, string.format("���ڽ�����ַ(%d/%d)\"%s\",��ȴ�..",ti+1,index,tbl_shorturls[str_index]));
		for tj = 0, 5, 1 do
			local str_son_url = urlprefix..tbl_shorturls[str_index];
			--dbgMessage(str_son_url);
			local tbl_sig = getTaskAttribute_acfun(str_son_url, str_tmpfile, str_servername, nil);
			if tbl_sig~=nil then
				--dbgMessage("has video");
				--dbgMessage(tbl_sig["0"]["descriptor"]);
				--dbgMessage(tbl_descriptors[str_index]);
				--tbl_sig["0"]["descriptor"] = tbl_sig["0"]["descriptor"].." - "..tbl_descriptors[str_index];
				local str_index2 = string.format("%d",index2);
				tbl_re[str_index2] = deepcopy(tbl_sig)["0"];--dumpmytable(tbl_sig["0"]);--
				index2 = index2+1;
				break;
			else
				--dbgMessage("parse error");
			end
		end

	end

	sShowMessage(pDlg, string.format("�������, ����%d����Ƶ",index2));

	return tbl_re;


end
