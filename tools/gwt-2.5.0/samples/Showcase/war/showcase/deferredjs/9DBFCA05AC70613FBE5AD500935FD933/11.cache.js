function rTb(){}
function vTb(){}
function kTb(a,b){a.b=b}
function lTb(a){if(a==aTb){return true}VD();return a==dTb}
function mTb(a){if(a==_Sb){return true}VD();return a==$Sb}
function tTb(a){this.b=(eVb(),_Ub).a;this.d=(lVb(),kVb).a;this.a=a}
function nTb(){eTb();kNb.call(this);this.b=(eVb(),_Ub);this.c=(lVb(),kVb);this.e[Gtc]=0;this.e[Htc]=0}
function iTb(a,b){var c;c=JH(a.ab,98);c.b=b.a;!!c.c&&(c.c[Etc]=b.a,undefined)}
function jTb(a,b){var c;c=JH(a.ab,98);c.d=b.a;!!c.c&&WJb(c.c,Ftc,b.a)}
function eTb(){eTb=Xmc;ZSb=new rTb;aTb=new rTb;_Sb=new rTb;$Sb=new rTb;bTb=new rTb;cTb=new rTb;dTb=new rTb}
function fTb(a,b,c){var d;if(c==ZSb){if(b==a.a){return}else if(a.a){throw new wcc('Only one CENTER widget may be added')}}rj(b);_4b(a.j,b);c==ZSb&&(a.a=b);d=new tTb(c);b.ab=d;iTb(b,a.b);jTb(b,a.c);hTb(a);tj(b,a)}
function gTb(a,b){var c,d,e,f,g,i,j;z4b(a.cb,xpc,b);i=new Akc;j=new k5b(a.j);while(j.a<j.b.c-1){c=i5b(j);g=JH(c.ab,98).a;e=JH(i.fd(g),144);d=!e?1:e.a;f=g==bTb?'north'+d:g==cTb?'south'+d:g==dTb?'west'+d:g==$Sb?'east'+d:g==aTb?'linestart'+d:g==_Sb?'lineend'+d:xtc;z4b(ur(c.cb),b,f);i.hd(g,Lcc(d+1))}}
function hTb(a){var b,c,d,e,f,g,i,j,k,n,o,p,q,r,s,t;b=a.d;while(hLb(b)>0){br(b,gLb(b,0))}q=1;e=1;for(i=new k5b(a.j);i.a<i.b.c-1;){d=i5b(i);f=JH(d.ab,98).a;f==bTb||f==cTb?++q:(f==$Sb||f==dTb||f==aTb||f==_Sb)&&++e}r=yH(m0,bnc,99,q,0);for(g=0;g<q;++g){r[g]=new vTb;r[g].b=$doc.createElement(Ctc);NJb(b,r[g].b)}k=0;n=e-1;o=0;s=q-1;c=null;for(i=new k5b(a.j);i.a<i.b.c-1;){d=i5b(i);j=JH(d.ab,98);t=$doc.createElement(Dtc);j.c=t;j.c[Etc]=j.b;WJb(j.c,Ftc,j.d);j.c[Zpc]=xpc;j.c[Xpc]=xpc;if(j.a==bTb){PJb(r[o].b,t,r[o].a);NJb(t,d.cb);t[wvc]=n-k+1;++o}else if(j.a==cTb){PJb(r[s].b,t,r[s].a);NJb(t,d.cb);t[wvc]=n-k+1;--s}else if(j.a==ZSb){c=t}else if(lTb(j.a)){p=r[o];PJb(p.b,t,p.a++);NJb(t,d.cb);t[twc]=s-o+1;++k}else if(mTb(j.a)){p=r[o];PJb(p.b,t,p.a);NJb(t,d.cb);t[twc]=s-o+1;--n}}if(a.a){p=r[o];PJb(p.b,c,p.a);NJb(c,a.a.cb)}}
z1(724,1,Rnc);_.lc=function jpb(){var a,b,c;h4(this.a,(a=new nTb,a.cb[Ypc]='cw-DockPanel',a.e[Gtc]=4,kTb(a,(eVb(),$Ub)),fTb(a,new yRb(lwc),(eTb(),bTb)),fTb(a,new yRb(mwc),cTb),fTb(a,new yRb(nwc),$Sb),fTb(a,new yRb(owc),dTb),fTb(a,new yRb(pwc),bTb),fTb(a,new yRb(qwc),cTb),b=new yRb('\u8FD9\u4E2A\u793A\u4F8B\u4E2D\u5728<code>DockPanel<\/code> \u7684\u4E2D\u95F4\u4F4D\u7F6E\u6709\u4E00\u4E2A<code>ScrollPanel<\/code>\u3002\u5982\u679C\u5728\u4E2D\u95F4\u653E\u5165\u5F88\u591A\u5185\u5BB9\uFF0C\u5B83\u5C31\u4F1A\u53D8\u6210\u9875\u9762\u5185\u7684\u53EF\u6EDA\u52A8\u533A\u57DF\uFF0C\u65E0\u9700\u4F7F\u7528IFRAME\u3002<br><br>\u6B64\u5904\u4F7F\u7528\u4E86\u76F8\u5F53\u591A\u65E0\u610F\u4E49\u7684\u6587\u5B57\uFF0C\u4E3B\u8981\u662F\u4E3A\u4E86\u53EF\u4EE5\u6EDA\u52A8\u81F3\u53EF\u89C6\u533A\u57DF\u7684\u5E95\u90E8\u3002\u5426\u5219\uFF0C\u60A8\u6050\u6015\u4E0D\u5F97\u4E0D\u628A\u5B83\u7F29\u5230\u5F88\u5C0F\u624D\u80FD\u770B\u5230\u90A3\u5C0F\u5DE7\u7684\u6EDA\u52A8\u6761\u3002'),c=new rOb(b),c.cb.style[Zpc]=rwc,c.cb.style[Xpc]=swc,fTb(a,c,ZSb),gTb(a,'cwDockPanel'),a))};z1(1029,985,fnc,nTb);_.Db=function oTb(a){gTb(this,a)};_.Wb=function pTb(a){var b;b=_Lb(this,a);if(b){a==this.a&&(this.a=null);hTb(this)}return b};_.a=null;var ZSb,$Sb,_Sb,aTb,bTb,cTb,dTb;z1(1030,1,{},rTb);z1(1031,1,{98:1},tTb);_.a=null;_.c=null;z1(1032,1,{99:1},vTb);_.a=0;_.b=null;var HW=fcc(uuc,'DockPanel',1029),GW=fcc(uuc,'DockPanel$TmpRow',1032),m0=ecc(Buc,'DockPanel$TmpRow;',1360,GW),EW=fcc(uuc,'DockPanel$DockLayoutConstant',1030),FW=fcc(uuc,'DockPanel$LayoutData',1031);Eoc(wn)(11);