# Community Credits & Research Provenance

This project grew from my own MINI work and from years of discussion and experimentation in the North American Motoring community. I want the repository to be clear about what I personally tested and where other people expanded the work.

## My contributions

### KOMBI / navigation reverse engineering

I personally documented or tested:

- R260 / Rosfar3000 bench work;
- Chrono → Navigation center-module conversion;
- EEPROM/FLASH backup and recovery;
- recovery of a corrupted donor;
- practical transfer regions `0x400-0x470` and `0x600-0x670`;
- successful use of those regions on multiple modules;
- HW30 Chrono vs. HW08 Navigation behavior in my swap;
- NCS Expert KMB/ZCS steps and INPA verification;
- follow-up troubleshooting and file exchange with forum members.

### Raspberry Pi head-unit project

I designed and integrated:

- the main Raspberry Pi integration PCB;
- the front rotary/menu/ambient-light PCB;
- the OEM-housing integration;
- factory connector and audio integration;
- startup/shutdown and vehicle-state behavior;
- display/rear-camera integration;
- multiple hardware/software iterations and the final installed workarounds.

## Other major contributors

- **ACGOG** — started the consolidated Chrono retrofit thread.
- **Warwick Dean** — VIN analysis, ZCS/coding guidance, FLASH/EEPROM and DME compatibility, troubleshooting.
- **keimanr** — R270 testing/recovery and compatibility findings.
- **thomm** — zero/low-mileage replacement approach and clarification of ZCS changes for a true Chrono retrofit.
- **YulCmr** — R270 recovery, known-good files, and the public [`mini_chrono_pack_BDM`](https://github.com/YulCmr/mini_chrono_pack_BDM) project; explicitly credited the EEPROM-region findings I had tested.
- **shrevemini** — real-world Chrono retrofit / pre-facelift experience.
- **cut7** — continued R270, VIN/mileage, and direct-sensor discussion.
- **shadoff** — R270 ribbon/pin confirmation and working zero-kilometer-file workflow.
- **North American Motoring community** — additional test cases, hardware combinations, files, and troubleshooting.


## Attribution standard

Throughout the documentation I try to distinguish:

- **personally tested** — I performed or reproduced it;
- **community tested** — another contributor documented it;
- **discussed / proposed** — it appeared in the research but I did not validate it.

## Primary sources

- [North American Motoring — R50/R53 Chrono Pack Retrofit](https://www.northamericanmotoring.com/forums/r50-r53-hatch-talk-2002-2006/344533-chrono-pack-retrofit-all-the-info-you-need-hopefully.html)
- [YulCmr / mini_chrono_pack_BDM](https://github.com/YulCmr/mini_chrono_pack_BDM)

If something is misattributed, please open an issue with the relevant source/post.
