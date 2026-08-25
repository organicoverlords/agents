// Flag repo-specific text that restates or contradicts the shared block.
import fs from "node:fs";
import path from "node:path";
const BEGIN="<!-- SHARED-AGENT-POLICY:BEGIN -->", END="<!-- SHARED-AGENT-POLICY:END -->";
const DEFAULT_TARGETS=[
 "C:/Users/Lauri/Documents/Unreal Projects/p3/AGENTS.md",
 "C:/Users/Lauri/Desktop/TinyLab/AGENTS.md",
 "C:/Users/Lauri/Desktop/lowvram3d-repo/AGENTS.md",
 "C:/Users/Lauri/Desktop/lowvram3d-studio-p0a-worktree/AGENTS.md",
 "C:/Users/Lauri/Desktop/AGENTS.md",
];
const TARGETS=process.env.POLICY_AUDIT_TARGETS
 ? process.env.POLICY_AUDIT_TARGETS.split(path.delimiter).filter(Boolean)
 : DEFAULT_TARGETS;
// topics the shared block now owns exclusively
const OWNED=[
 [/only pause for|second approval|push through .*failures|BLOCKED/i,"continuity/authorization"],
 [/\bBUSY\b|mutation coordination|serializ/i,"coordination"],
 [/PROVEN|should work|supporting evidence|visual claim/i,"proof"],
 [/never (close|restart|kill|hijack)|UAC|SmartScreen|user-owned/i,"user-owned machine"],
 [/credential|secret|token|\.env/i,"secrets"],
 [/outrank|stale prose|precedence/i,"precedence"],
];
let findings=0;
for(const t of TARGETS){
  if(!fs.existsSync(t)){console.error(`MISSING ${t}`); findings++; continue;}
  const raw=fs.readFileSync(t,"utf-8").split(/\r?\n/).join("\n");
  const s=raw.indexOf(BEGIN), e=raw.indexOf(END);
  if(s<0||e<s){console.error(`MALFORMED ${t}`); findings++; continue;}
  const outside=(raw.slice(0,s)+raw.slice(e+END.length)).split("\n");
  const hits=[];
  outside.forEach((l,i)=>{
    if(!l.trim()||l.trim().startsWith("<!--")) return;
    for(const [re,topic] of OWNED) if(re.test(l)) { hits.push({topic,line:l.trim().slice(0,105)}); break; }
  });
  if(hits.length){ findings+=hits.length; console.log(`\n### ${t}`); hits.forEach(h=>console.log(`  [${h.topic}] ${h.line}`)); }
}
console.log(findings?`\n${findings} repo-section line(s) touch shared-owned topics — review each`:"\nno repo section touches a shared-owned topic");
if(findings) process.exit(1);
