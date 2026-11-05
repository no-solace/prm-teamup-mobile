"""Sinh 3 flow (.drawio + .png) tu cung mot dac ta. Chay: python3 build_flows.py"""
import matplotlib; matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Polygon
from xml.sax.saxutils import quoteattr
import os
os.chdir(os.path.dirname(os.path.abspath(__file__)))
W,H,DW,DH,GX,STEP,X0,Y0=300,64,220,84,440,116,40,60
ST={ # kind: (fill, stroke, dashed)
 "start":("#D6F0DD","#1B6B3C",0),"end":("#D6F0DD","#1B6B3C",0),
 "screen":("#FFE2D2","#B23E00",0),"dec":("#FFF2CC","#8A6D00",0),"err":("#F9DEDC","#B3261E",1)}
def build(name,title,nodes,edges):
    pos={}
    for i,k,t,c,r in nodes:
        w,h=(DW,DH) if k=="dec" else (W,H)
        pos[i]=(X0+c*GX+(W-w)/2,Y0+r*STEP+(H-h)/2,w,h,k,t)
    maxr=max(n[4] for n in nodes); maxc=max(n[3] for n in nodes)
    pw=X0*2+maxc*GX+W; ph=Y0+maxr*STEP+H+40
    # ---- drawio
    x=[f'<mxCell id="title" value={quoteattr(title)} style="text;fontSize=16;fontStyle=1;align=left;" vertex="1" parent="1"><mxGeometry x="40" y="10" width="700" height="30" as="geometry"/></mxCell>']
    for i,(px,py,w,h,k,t) in pos.items():
        f,s,d=ST[k]
        shape="rhombus" if k=="dec" else ("rounded=1;arcSize=50" if k in("start","end") else "rounded=1;arcSize=12")
        sw=2.5 if k=="screen" else 1.5
        x.append(f'<mxCell id="{i}" value={quoteattr(t)} style="{shape};whiteSpace=wrap;html=0;fillColor={f};strokeColor={s};strokeWidth={sw};fontSize=12;fontColor=#1C1B18;{"dashed=1;" if d else ""}" vertex="1" parent="1"><mxGeometry x="{px}" y="{py}" width="{w}" height="{h}" as="geometry"/></mxCell>')
    for n,(a,b,l,*o) in enumerate(edges):
        x.append(f'<mxCell id="e{n}" value={quoteattr(l)} style="edgeStyle=orthogonalEdgeStyle;rounded=1;endArrow=block;fontSize=11;strokeColor=#55534D;" edge="1" parent="1" source="{a}" target="{b}"><mxGeometry relative="1" as="geometry"/></mxCell>')
    open(f"{name}.drawio","w",encoding="utf-8").write(f'<?xml version="1.0" encoding="utf-8"?><mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" page="1" pageWidth="{pw}" pageHeight="{ph}"><root><mxCell id="0"/><mxCell id="1" parent="0"/>'+"".join(x)+'</root></mxGraphModel>')
    # ---- png
    fig=plt.figure(figsize=(pw/100,ph/100),dpi=100); ax=fig.add_axes([0,0,1,1]); ax.set_xlim(0,pw); ax.set_ylim(ph,0); ax.axis("off")
    ax.text(40,24,title,fontsize=15,fontweight="bold",va="center")
    for i,(px,py,w,h,k,t) in pos.items():
        f,s,d=ST[k]; ls="--" if d else "-"; lw=2.4 if k=="screen" else 1.4
        if k=="dec": ax.add_patch(Polygon([(px+w/2,py),(px+w,py+h/2),(px+w/2,py+h),(px,py+h/2)],fc=f,ec=s,lw=lw,zorder=2))
        else: ax.add_patch(FancyBboxPatch((px,py),w,h,boxstyle=f"round,pad=0,rounding_size={h/2 if k in('start','end') else 8}",fc=f,ec=s,lw=lw,ls=ls,zorder=2))
        ax.text(px+w/2,py+h/2,t,ha="center",va="center",fontsize=9.5,color="#1C1B18",zorder=3,linespacing=1.3)
    for n,(a,b,l,*o) in enumerate(edges):
        ty=(o[0] if o else 0)
        ax_,ay,aw,ah=pos[a][:4]; bx,by,bw,bh=pos[b][:4]
        acx,acy,bcx,bcy=ax_+aw/2,ay+ah/2,bx+bw/2,by+bh/2+ty
        if abs(acx-bcx)<5: pts=[(acx,ay+ah if bcy>acy else ay),(bcx,by if bcy>acy else by+bh)]
        else:
            right=bcx>acx; sx=ax_+aw if right else ax_; tx=bx if right else bx+bw
            if abs(acy-bcy)<5:
                dy=0 if (b,a,'') not in [(e[0],e[1],'') for e in edges] else (8 if a>b else -8)
                pts=[(sx,acy+dy),(tx,bcy+dy)]
            else:
                xm=(sx+tx)/2+(n%5-2)*16; pts=[(sx,acy),(xm,acy),(xm,bcy),(tx,bcy)]
        for p,q in zip(pts[:-2],pts[1:-1]): ax.plot([p[0],q[0]],[p[1],q[1]],color="#55534D",lw=1.3,zorder=1)
        ax.annotate("",xy=pts[-1],xytext=pts[-2],arrowprops=dict(arrowstyle="-|>",color="#55534D",lw=1.3),zorder=1)
        if l: ax.text((pts[0][0]+pts[1][0])/2+4,(pts[0][1]+pts[1][1])/2-8,l,fontsize=8.5,color="#55534D",ha="left",zorder=4,bbox=dict(fc="white",ec="none",pad=1))
    fig.savefig(f"{name}.png"); plt.close(fig)

build("flow-a","Flow A - Duyệt gợi ý AI cho một lớp",[
 ("a0","start","START\nMentor mở app",0,0),
 ("a1","screen","S1 Sign in\nNhập email",0,1),
 ("a2","dec","Email\nhợp lệ?",0,2),("a2e","err","S19 Sign in, lỗi\n'Enter a valid email'",1,2),
 ("a3","screen","S2 My classes\nChọn một lớp",0,3),("a3i","screen","S22 Import class list\nChọn file MSSV, lớp, nhóm, ngành",1,3),("a3r","screen","S23 Import result\nẨn SV đã có nhóm, nhóm đủ 6",1,4),
 ("a4","screen","S3 Class detail\nXem số SV chưa có nhóm",0,4),
 ("a5","screen","S4 No team\nXem danh sách, lọc theo ngành",0,5),
 ("a6","screen","S8 AI matching\nBấm Match with AI, chờ",0,6),
 ("a7","dec","Kết nối\nổn?",0,7),("a7e","err","S18 Offline\n'You're offline' + Try again",1,7),
 ("a8","screen","S9 Proposals\nDanh sách nhóm đề xuất",0,8),
 ("a9","screen","S10 Proposal detail\nXem lý do và thành viên mới",0,9),
 ("a10","screen","S12 Approve dialog\nBấm Approve",0,10),
 ("a11","screen","S14 Proposals\nSnackbar 'Approved'",0,11),
 ("a12","end","END\nNhóm đã duyệt, SV được báo",0,12)],
 [("a0","a1",""),("a1","a2",""),("a2","a3","Hợp lệ"),("a2","a2e","Sai"),("a2e","a1","Nhập lại"),("a3","a4",""),("a3","a3i","Import"),("a3i","a3r",""),("a3r","a4","Mở lớp"),("a4","a5",""),("a5","a6",""),
  ("a6","a7",""),("a7","a8","Có"),("a7","a7e","Không"),("a7e","a6","Try again"),("a8","a9",""),("a9","a10",""),("a10","a11","Approve"),("a11","a12","")])

build("flow-b","Flow B - Thêm thành viên vào đề xuất",[
 ("b0","start","START\nMentor mở tab Proposals",0,0),
 ("b1","screen","S9 Proposals\nChọn một nhóm đề xuất",0,1),
 ("b2","screen","S10 Proposal detail\nBấm Add member",0,2),
 ("b3","screen","S11 Add member\nTick SV muốn thêm",0,3),("b3s","screen","S7 Student detail\nXem MSSV, lớp, ngành",1,3),
 ("b4","dec","Tổng ≤ 6\nngười?",0,4),("b4e","err","S13 Add member lỗi\n'Max 6 members', khóa nút Add",1,4),
 ("b5","screen","S10 Proposal detail\nĐã cập nhật thành viên",0,5),("b5r","screen","S24 Remove member\nXác nhận bỏ một thành viên",1,5),("b5b","err","S25 Approve blocked\nDưới 5 người: khóa Approve",1,6),
 ("b6","screen","S12 Approve dialog\nBấm Approve",0,6),
 ("b7","screen","S14 Proposals\nSnackbar 'Approved'",0,7),
 ("b8","end","END\nNhóm đủ 4-6 người đã duyệt",0,8)],
 [("b0","b1",""),("b1","b2",""),("b2","b3",""),("b3","b3s","Xem hồ sơ"),("b3s","b3","Quay lại"),("b3","b4",""),("b4","b5","Có"),("b4","b4e","Không"),("b4e","b3","Bỏ bớt",16),
  ("b5","b6",""),("b5","b5r","Remove"),("b5r","b5b","Remove"),("b5b","b5","Add member",16),("b6","b7","Approve"),("b7","b8","")])

build("flow-c","Flow C - AI không ghép được, mentor ghép tay",[
 ("c0","start","START\nBấm Match with AI ở S3",0,0),
 ("c1","screen","S8 AI matching\nChờ kết quả",0,1),
 ("c2","dec","AI tìm được\nSV phù hợp?",0,2),("c2n","screen","S15 No match\n'No Design student found'",1,2),
 ("c3","end","Có: sang S9 Proposals\n(tiếp Flow A)",0,3),("c4","screen","S5 Need members\nXem nhóm còn thiếu ngành",1,3),
 ("c5","screen","S16 Add student\nChọn SV chưa có nhóm",1,4),("c14","screen","S21 Add student\nKhông có kết quả",2,4),
 ("c6","dec","SV chưa\ncó nhóm?",1,5),("c6e","err","LỖI: dòng 'In a team'\nbị khóa, không chọn được",0,5),
 ("c7","screen","S20 Proposal detail\nNhóm đã thêm tay",1,6),
 ("c8","dec","Duyệt\nhay bỏ?",1,7),("c11","screen","S17 Discard dialog\nBấm Discard (nút đỏ)",0,7),
 ("c9","screen","S12 Approve dialog\nBấm Approve",1,8),("c12","end","END\nVề S9 Proposals",0,8),
 ("c10","screen","S14 Proposals\nSnackbar 'Approved'",1,9),("c13","end","END\nNhóm đã duyệt",1,10)],
 [("c0","c1",""),("c1","c2",""),("c2","c3","Có"),("c2","c2n","Không"),("c2n","c4","Add manually"),("c4","c5",""),("c5","c6",""),("c5","c14","Tìm không ra"),("c14","c5","Clear search"),
  ("c6","c7","Có"),("c6","c6e","Không"),("c6e","c5","Chọn lại"),("c7","c8",""),("c8","c9","Approve"),("c8","c11","Discard"),("c11","c12",""),("c9","c10",""),("c10","c13","")])
