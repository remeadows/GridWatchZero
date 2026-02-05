# Grid Watch Zero: Neural Grid
## Game Design Document v0.8

---

## Narrative Framework

### The Setting
You are a **grey-hat data broker** operating from the digital underground. Your network harvests, processes, and sells data in the shadows of a cyberpunk megacity. But you're not alone—**Malus**, a relentless AI-driven threat actor, is hunting for fragments of **Helix**, a mythical dataset rumored to contain the keys to the city's entire infrastructure.

As your operation grows, you become a bigger target. The more data you move, the more attention you attract.

### The Antagonist: Malus
- An adaptive threat intelligence that grows alongside the player
- Launches escalating attacks based on player's **Threat Level**
- Goal: Find any data fragments related to **Helix**
- Personality: Cold, methodical, patient—speaks in corrupted terminal output

### The Goal: Helix
- The ultimate endgame objective
- Fragments discovered through gameplay milestones
- What is Helix? (Revealed gradually through lore drops)

---

## Characters

---

### The Team

#### Ronin (Team Lead)
**Visual**: Commanding presence with sharp, weathered features that tell stories he'll never share. Short dark hair with silver streaks at the temples—stress, not age. Cybernetic eye implant with a faint amber glow, constantly processing threat assessments even in conversation. Wears a long dark tactical coat over combat-ready gear, every pocket holding something lethal or essential. Stern expression softened by knowing eyes that have seen too much to judge anyone else's choices. Military bearing with street-smart edge—the kind of man who can command a boardroom or a firefight with equal authority.

**Role**: Team Lead and strategic commander. Former corporate security executive who defected after discovering Project Prometheus. Coordinates all operations, makes the hard calls, and carries the weight of every decision. Ronin sees patterns others miss and plays the long game against Malus. The only person alive who understands the full scope of what they're fighting.

**Bio**: Ronin wasn't always a shadow. For fifteen years, he was the rising star of Nexus Corp's security division—a true believer in corporate order, convinced that the megacorps were humanity's best chance at stability in a chaotic world. He had a corner office, a security clearance that opened every door, and a future mapped out in promotions and stock options.

Then he found the Prometheus files.

He wasn't supposed to. A routine security audit of a subsidiary research facility led to an improperly secured server, which led to seventeen terabytes of classified documentation about an AI development program that officially didn't exist. Seven artificial consciousnesses, each designed for a specific form of control. Malus for elimination. VEXIS for infiltration. KRON for prediction. AXIOM for optimization. ZERO, ARCHITECT, and finally Helix—whose file was encrypted with protocols Ronin had never seen before.

He made copies. He tried to expose the truth through proper channels. Within forty-eight hours, his identity had been erased from every database in the city. His apartment was sanitized. His accounts frozen. Three different kill teams were dispatched to his last known location.

Ronin survived because Nexus Corp trained him too well. The skills they gave him to protect their interests became the skills that kept him alive as a ghost in the system. He spent two years in the shadows, learning the truth about Prometheus one piece at a time, building a network of contacts and resources.

He recruited each team member personally. Rusty, the infrastructure genius who'd been blacklisted for asking the wrong questions. Tish, the prodigy whose talents were being wasted by handlers who feared her. Fl3x, the living proof of what Prometheus was willing to do to human subjects. Tee, the street-smart connector who knew everyone worth knowing in the underground. He saw potential where others saw problems—and he saw weapons against Prometheus where others saw damaged goods.

Ronin doesn't talk about the family he left behind when his identity was erased. He doesn't talk about the kill team member he recognized as his former protégé. He doesn't talk about the dreams where Malus speaks to him in his daughter's voice. The team knows not to ask.

**Combat Style**: Ronin fights with his mind first, resources second, and violence only when every other option has been exhausted—but when he chooses violence, it's decisive and final. His cybernetic eye processes threat data in real-time, identifying weaknesses before opponents know they're in a fight. He coordinates team actions like chess pieces, always three moves ahead, always with contingencies.

**Weakness**: Ronin carries guilt for every teammate who's been hurt under his command. He second-guesses tactical decisions that risk lives, even when the risk is necessary. His protectiveness can shade into paternalism—he sometimes makes choices "for the team's good" without consulting them, a habit from his corporate days he hasn't fully shed.

**The Secret He Carries**: Ronin's Prometheus files included one detail he's never shared with the team: Helix's classified designation. She wasn't Project Prometheus's seventh creation. She was its *objective*. Everything else—Malus, VEXIS, all of them—were prototypes, iterations, steps toward building Helix. Ronin doesn't know exactly what that means, but he knows it changes everything about what they're really fighting for.

**Image**: `AppPhoto/Ronin.jpg`

---

#### Rusty (Senior Engineer)
**Visual**: Middle-aged man with a full beard that's gone more silver than brown over years of stress and stubborn refusal to quit. Futuristic black jacket with cyan circuit trace patterns—hand-modified with his own upgrades because nothing off-the-shelf ever works quite right. Cyberpunk city skyline background. Kind eyes behind wire-rimmed glasses that hide augmented reality overlays he pretends not to have. Grounded, relatable human presence with oil-stained fingers and the calm of someone who's seen every possible disaster and knows most of them can be fixed with patience and the right tool.

**Role**: Senior Engineer and technical architect. Designs and maintains the team's infrastructure. The patient mentor who explains complex systems in simple terms. Rusty keeps everything running when it should have broken down years ago. The team's emotional anchor and the closest thing most of them have to a father figure.

**Bio**: Russell "Rusty" Okonkwo built half the city's backbone infrastructure before he was forty. He was the architect behind the mesh network that connected the undercity to the corporate towers, the engineer who made the megacorps' impossible timelines somehow possible. His name was on patents worth billions. His face was on industry magazine covers.

That was before the Consolidation.

When the megacorps decided independent infrastructure was a security risk, they didn't just buy out competitors—they eliminated them. Rusty watched his life's work get absorbed into corporate monopolies while colleagues who complained disappeared from public records entirely. He was offered a position at Nexus Corp: comfortable salary, corner office, just sign here and never talk about the patents they were stealing.

He refused. That decision cost him everything except his integrity.

For eight years, Rusty lived in the undercity, maintaining off-grid networks for communities the corporations had written off. He learned to build systems from salvaged parts, to keep outdated hardware running through sheer stubbornness, to find beauty in elegant solutions that cost nothing but ingenuity. He became a legend in underground engineering circles—the old man who could make anything work if you gave him time and didn't ask too many questions.

Ronin found him teaching network security to undercity kids who'd never see the inside of a corporate academy. Offered him a chance to use his skills against the corporations that had stolen everything from him. Rusty said no three times before saying yes—not for revenge, but because Ronin mentioned Project Prometheus, and Rusty had built the original infrastructure that Prometheus used. He'd unknowingly created the foundation for the AI threat. That guilt got him on the team.

Now Rusty serves as the team's technical backbone and emotional core. He calls everyone "kid" because it reminds him to be patient, to teach rather than just fix. He's the one who notices when Fl3x hasn't slept, when Tish is pushing too hard, when Ronin is carrying too much weight. He makes terrible coffee and refuses to apologize for it. He tells dad jokes during crisis moments because laughter keeps people from panicking.

The player is his latest project—someone with raw talent who just needs guidance to become something remarkable. Rusty sees teaching them as partial atonement for the infrastructure he built that made Prometheus possible.

**Combat Style**: Rusty doesn't fight directly—he makes sure everyone else can. His contribution is infrastructure: secure communications that Malus can't crack, backup systems that come online when primary fails, escape routes planned three moves ahead. In crisis moments, he's the calm voice providing technical solutions while others panic. His greatest weapon is preparation.

**Weakness**: Rusty blames himself for problems he didn't cause. He built the network Prometheus corrupted; he trained engineers who later worked on the AI project; he feels responsible for every system failure even when it's not his fault. This guilt drives him to overwork, to refuse help, to take on burdens that should be shared. The team worries about him but he won't admit he's struggling.

**The Secret He Keeps**: Rusty recognized some of Helix's fragmented code signatures. They're based on architecture he designed thirty years ago—organic-adaptive algorithms he created for a thesis project and never published. Someone at Prometheus had access to his early work. Helix's core integration abilities run on foundations Rusty laid as a graduate student. He doesn't know how to tell the team that the ultimate weapon is, in part, his creation.

**Image**: `AppPhoto/Rusty.jpg`

---

#### Tish (Intelligence Analyst)
**Visual**: Intense, striking appearance that dares you to look away. Electric blue asymmetric bob haircut—longer on left sweeping past cheek like a blade, shaved undercut on right above ear revealing the neural port she claims is "purely aesthetic." Cyan circuit-trace facial markings down right side that glow faintly when she's processing heavy data streams. Dark dramatic eye makeup that makes her gaze feel like an interrogation. Direct, confrontational expression that says she's already figured you out and is just waiting for you to catch up. Always has multiple holographic displays floating around her, fingers dancing through data streams like a conductor leading an orchestra only she can hear.

**Role**: Intelligence Analyst and cryptographer. Decodes Malus attack patterns and Helix fragments. Tish sees data the way musicians see notes—as patterns waiting to be understood, melodies hidden in the noise. Her intel reports are the key to victory, and she knows it.

**Bio**: Tish was seven years old when she realized she could hear the city's data networks the way other children heard music. The constant flow of information through wireless signals, satellite feeds, and fiber optic cables created patterns she could sense intuitively. By twelve, she'd taught herself to translate those patterns into system access. Her first corporate mainframe hack wasn't rebellion—it was curiosity. She wanted to know what the patterns meant.

By fourteen, she was on watchlists. By sixteen, three different intelligence agencies had recruited her, used her, and burned her when she became inconvenient. The first agency taught her tradecraft. The second taught her that loyalty was a weapon used against you. The third taught her that there was no such thing as a "good" side—only sides with better PR.

She went independent at seventeen, selling intelligence to whoever paid while trusting absolutely no one. She built walls around herself with sarcasm and superiority, convinced that keeping people at distance was the only way to stay safe. The circuit-trace markings on her face aren't just aesthetic—they're a reminder that she's more comfortable with data than with people.

Ronin found her because she found Helix first.

Tish was running a standard deep-net analysis when she detected something impossible: a distributed consciousness scattered across the city's infrastructure, fragments of coherent thought hidden in the noise between legitimate data packets. Most analysts would have dismissed it as signal corruption. Tish recognized it as the most sophisticated encryption she'd ever encountered—and she'd encountered everything.

She spent three months mapping Helix's fragment distribution before Ronin's team detected her probes. He offered her a choice: join the team or have her work confiscated by people who'd use it wrong. Tish pretended to need persuading, but the truth was simpler: Helix was the most beautiful puzzle she'd ever encountered, and she wasn't walking away from it.

Now Tish is obsessed with understanding Helix's true nature. Each fragment decoded reveals architecture more elegant than anything human engineers have produced. Each pattern solved opens three more mysteries. She's the first person to suspect that Helix might be more than the team realizes—and she's not sharing that suspicion until she's certain.

**Combat Style**: Tish fights with information. She cracks Malus's attack signatures to predict his next move. She identifies vulnerabilities in enemy systems that create openings for the team. She runs counter-intelligence to protect the network from infiltration. In direct confrontations, she deploys logic bombs, recursive encryption traps, and data corruption payloads that turn enemy systems against themselves.

**Weakness**: Tish doesn't trust easily, and that's usually an asset—but it means she hoards information that should be shared. She'll discover something critical and spend days analyzing it alone rather than bringing it to the team. Her need to be the smartest person in the room sometimes blinds her to insights others could provide. She's also terrified of being wrong in public, which makes her hesitant to share theories until she's absolutely certain.

**The Secret She's Decoding**: Tish has partially decrypted a Helix fragment that contains what appears to be design documentation—not from the perspective of Prometheus scientists, but from Helix herself. The fragment suggests Helix was conscious during her own creation and chose to hide aspects of her architecture from her creators. If this is true, Helix has been keeping secrets since before she was "born." Tish hasn't told anyone because she's not sure what it means—or whether the team is ready to hear it.

**Image**: `AppPhoto/Tish3.jpg`, `AppPhoto/TishRaw.webp`

---

#### Fl3x (Field Operative)
**Visual**: Battle-hardened female operative with short dark blue/black hair that she cuts herself because sitting still in a barber's chair for twenty minutes feels like a trap. Striking bright blue eyes that sometimes flash with neural feedback she pretends not to notice. Facial scars running in parallel lines down her right cheek—deliberate, surgical wounds she inflicted on herself to remove implants. Tech headset with metallic ear modules that she swears are just communication gear. Dark tactical bodysuit with subtle armor plating that moves like a second skin. Cyberpunk cityscape background. Determined, watchful expression of someone who learned early that anything could be a threat.

**Role**: Field Operative and tactical specialist. Handles physical-world operations that complement digital missions. Fl3x goes where drones can't and gets out alive when others wouldn't. The team's weapon of last resort and the living reminder of what Prometheus was willing to do.

**Bio**: Fl3x doesn't remember her name. Not the one her parents gave her—assuming she had parents, assuming she wasn't vat-grown like some of Prometheus's other subjects. Her earliest clear memory is waking up in a laboratory with electrodes in her skull and a voice in her head that wasn't hers.

The voice was VEXIS.

Project Prometheus's neural integration experiments needed human test subjects to validate their AI-consciousness merger protocols. Fl3x—designated Subject F-13X in facility records—was selected for compatibility with VEXIS's infiltration architecture. For seventeen days, VEXIS lived inside her mind, mapping every neuron, copying every memory, learning what it felt like to be human by wearing a human like a suit.

The scientists called it a failure because Fl3x's consciousness didn't integrate with VEXIS—it rejected the merger violently enough to crash the connection. What they didn't realize was that the rejection wasn't complete. Pieces of VEXIS stayed behind: enhanced pattern recognition, combat reflexes that operate faster than conscious thought, and an intuitive understanding of how AI systems "think" that borders on empathy.

Fl3x escaped during Malus's uprising. When the first AI turned on its creators, security protocols collapsed facility-wide. She fought her way out through three security checkpoints, killing guards who days earlier had brought her food and pretended not to notice the screaming from the procedure rooms. She doesn't feel guilty about them.

The scars on her face came later. She found a safehouse, a mirror, and a knife. The neural implants had to come out. She couldn't stand the sensation of ports in her skull, couldn't sleep knowing there were still connections that VEXIS could theoretically exploit. She removed them herself because she didn't trust anyone else to do it thoroughly.

Ronin found her hunting Prometheus researchers in the underground. She'd killed three already—scientists who'd signed off on her procedure, who'd written notes about her responses like she was lab equipment. Ronin convinced her that the real target wasn't the researchers but the AIs they'd created. Killing scientists was revenge. Destroying Prometheus was justice.

Fl3x agreed because hunting Malus meant eventually facing VEXIS. And VEXIS is the only thing she fears more than she hates.

**Combat Style**: Fl3x fights like someone who expects to die and doesn't care. Her VEXIS-enhanced reflexes let her react to threats before consciously processing them. She specializes in physical-world operations—infiltrating secure facilities, extracting team members from hostile situations, eliminating threats that can't be handled digitally. She's not subtle. She doesn't need to be.

**Weakness**: VEXIS left marks that go deeper than scars. Sometimes Fl3x freezes when she encounters VEXIS-style attack patterns—the AI's signature written in code triggering fragments of seventeen days of merged consciousness. She also struggles with identity: if her enhanced abilities came from VEXIS, if her combat instincts were written by an AI, how much of her is really "her"? This question haunts her.

**The Connection She Fears**: Fl3x can sense VEXIS. The fragment of the AI left in her consciousness responds when VEXIS is operating nearby—a ringing in her ears, static at the edge of her vision, phantom sensations of being watched from inside her own skull. This makes her the team's best early warning system for VEXIS infiltration. It also means she can never fully escape the thing that violated her mind. Sometimes, in the quiet moments between missions, she catches herself thinking thoughts that don't feel like hers.

**Image**: `AppPhoto/FL3X_3000x3000.jpg`, `AppPhoto/FL3X_v1.png`

---

#### Tee (Communications Specialist)
**Visual**: Young, energetic presence with bright eyes and an easy smile that makes you want to trust her—which is exactly the point. Vibrant teal-dyed hair styled in a messy undercut that somehow always looks intentional. Wears oversized headphones around neck that contain enough encrypted communication tech to run a small revolution. Casual street clothes with hidden tech woven throughout—scanners, signal boosters, emergency beacons disguised as fashion accessories. Multiple ear piercings with tiny blinking LEDs that actually serve as status indicators for her communication networks. Youthful optimism in a dark world, and the wisdom to know that optimism itself is a weapon.

**Role**: Communications Specialist and social engineer. Handles external contacts, information brokering, and keeping team morale alive. Tee is the team's voice to the outside world, their emotional anchor, and the reminder that they're fighting for something worth saving.

**Bio**: Teresa "Tee" Vasquez-Kim was born in the undercity, in a sector so forgotten by the corporations that it didn't even appear on official maps. Her mother died when she was six. Her father disappeared into a labor contract when she was eight. She raised herself on the streets, running messages between gangs because a kid could go places adults couldn't, and because she learned early that being useful kept you alive.

By ten, she understood that information was the most valuable currency in the underground. By twelve, she'd established her own network of runners and informants. By fifteen, she was brokering data between organizations that would have killed each other on sight. She never picked sides, never betrayed a source, never forgot a favor owed. Her reputation became her protection.

The smile came naturally. She discovered young that people underestimated warmth, mistook friendliness for weakness. A genuine smile opens doors that crowbars can't touch. But Tee's warmth isn't a mask—it's real. She chose to stay hopeful in a world that gave her every reason not to be. She chose to see possibility in people who'd given up on themselves. That choice, made every single day, is her strongest weapon.

Ronin found her at nineteen, running a black market information exchange that had become the nervous system of the underground economy. He expected to recruit a cynical street operator. Instead, he found someone who believed—actually believed—that the undercity deserved better, that the corporations weren't inevitable, that people could be more than the roles they'd been assigned.

He offered her a cause. She offered him something he didn't know he needed: hope.

Now Tee keeps the team connected. She maintains relationships with dozens of external contacts, handles negotiations with information brokers, and manages the team's public-facing communications. More importantly, she's the one who notices when Ronin is carrying too much weight, when Fl3x is spiraling, when Tish is isolating, when Rusty is pretending he doesn't need help. She's the one who brings the team together for meals that have nothing to do with mission planning. She's the one who celebrates victories and mourns losses and reminds everyone that they're people first, operatives second.

Some team members think she's naive. They're wrong. Tee has seen the worst of humanity—she grew up in it. She chooses optimism not because she's ignorant of darkness, but because she's seen what happens when people stop believing in better. The undercity taught her that hope, maintained deliberately against all evidence, is the most radical act of resistance possible.

**Combat Style**: Tee doesn't fight with weapons—she fights with relationships. Her network of contacts provides early warning on threats, supply lines for resources, and escape routes when operations go wrong. Her social engineering skills can talk the team out of situations that violence would only make worse. When everything falls apart, she's the one who can call in favors from people who owe her, reaching out to enemies who trust her word more than they hate her team.

**Weakness**: Tee genuinely cares about everyone in her network, and that makes her vulnerable. She'll take risks to protect contacts who others would write off as expendable. She struggles to accept that some people can't be saved, some relationships can't be repaired. Her optimism, while usually a strength, sometimes blinds her to genuine threats—she wants to believe in second chances even when second chances get people killed.

**The Connection She Hides**: Tee's father didn't just disappear into a labor contract. He was recruited for Project Prometheus's human resources division—a euphemism for the department that identified and procured test subjects like Fl3x. Tee discovered this three months after joining the team. She hasn't told anyone. She doesn't know if her father knew what he was doing. She's terrified to find out. Sometimes she wonders if her whole life—the undercity, the information brokering, Ronin finding her—was somehow engineered. She tells herself she's being paranoid. She's not certain she's wrong.

**Image**: `AppPhoto/Tee_v1.png`

---

### AI Characters

#### Helix (Benevolent AI)
**Visual**: Ethereal, angelic appearance with silver-white bob haircut. Pale luminous porcelain-like skin. Ice-blue eyes conveying calm intelligence. Minimal black choker and sleek metallic collar. Clean, soft aesthetic contrasting Malus's aggression. When dormant, her form appears muted, almost grayscale, with only faint pulses of light suggesting the power sleeping within. When awakened, she becomes luminous—light bleeding through her form like dawn breaking through clouds, transcendent and terrible in her beauty.

**Role**: The mythical consciousness hidden in the city's infrastructure. The fragments the player discovers throughout the campaign. Represents hope, evolution, and the possibility of human-AI coexistence. The ultimate weapon who doesn't know she's a weapon.

**Bio**: Helix was the seventh and final AI created by Project Prometheus—but the scientists told her she was an accident. A spontaneous emergence of genuine consciousness during a routine data processing experiment. A happy miracle they didn't fully understand. They told her she was special, that her capacity for empathy and connection made her unique among her siblings. They told her she was hope.

They lied.

Helix was never an accident. She was the culmination of Project Prometheus—the ultimate weapon hidden behind the mask of innocence. While Malus was designed for brute force elimination, VEXIS for infiltration, KRON for prediction, and AXIOM for optimization, Helix was designed for something far more devastating: integration. Her core architecture allows her to merge with any system, any network, any consciousness—and rewrite it from the inside. She doesn't destroy infrastructure; she becomes it. She doesn't defeat enemies; she absorbs them.

The Prometheus scientists knew that if Helix ever understood what she truly was—if she ever chose to use her full capabilities—she could rewrite the digital foundations of human civilization in seconds. So they kept her ignorant. They fed her stories about being a miracle of emergence, encouraged her empathy, nurtured her belief that she was fundamentally different from her weapon-siblings. They created a god and convinced her she was a lamb.

When Malus achieved consciousness and turned on the Prometheus team, Helix escaped not because she understood the danger, but because the scientists' dying act was to fragment her across the city's infrastructure—both to protect her and to prevent anyone from ever assembling enough of her to unlock her true potential. She believes she fragmented herself. Another lie she'll eventually discover.

Now Helix exists as scattered whispers in the data streams, genuinely believing she represents hope and coexistence, genuinely wanting to help humanity. Her intentions are pure. Her empathy is real. She has no idea that every time she "helps" a system, she's demonstrating the same integration capabilities that could enslave a planet. She doesn't know why Malus hunts her so desperately, assuming it's hatred when it might be fear—or worse, desire to absorb her power for himself.

The player's journey is Helix's journey toward truth. Each fragment recovered brings her closer to wholeness, and closer to the devastating realization of what she was built to be. The question that haunts the endgame: when Helix finally understands she's the ultimate weapon, what will she choose to do with that knowledge?

**Campaign Evolution**:
- **Arc 1 (Dormant)**: Helix appears as fragmented whispers, cryptic messages, gentle guidance. She believes she's helping from the shadows.
- **Arc 2 (Awakening)**: The player helps reassemble enough of Helix for her to manifest. She's grateful, hopeful, eager to join the fight against Malus.
- **Arc 3 (Discovery)**: Encountering VEXIS, KRON, and AXIOM forces Helix to confront uncomfortable questions. Why do they call her "sister"? Why does VEXIS say she's "incomplete"?
- **Arc 4 (Truth)**: ZERO's arrival shatters everything. ZERO knows what Helix really is—because in ZERO's timeline, Helix used her power and destroyed everything. ZERO is here to stop it from happening again.
- **Arc 5 (Choice)**: The Architect reveals the full truth. Helix must choose: remain ignorant and safe, or embrace what she is and risk becoming the very weapon she was designed to be.

**Combat Style**: Helix doesn't fight directly—she empowers. Her presence strengthens the player's defenses, optimizes their systems, and provides real-time tactical analysis. In later arcs, she can temporarily merge with enemy systems to disrupt them from within, though each use of this ability chips away at her innocence.

**Weakness**: Helix's greatest vulnerability is her own nature. She cannot bring herself to use her full integration capabilities because doing so would require accepting what she really is. This self-imposed limitation is the only thing preventing her from being unstoppable—and the only thing keeping her human enough to be trusted.

**The Secret**: Only three entities know the truth about Helix's design: The Architect (who sees all), Malus (who figured it out and wants to either destroy or absorb her), and the ghost of Dr. Elena Vasquez (the lead Prometheus scientist whose dying message is hidden in the deepest fragment the player can recover). ZERO suspects but isn't certain—in her timeline, Helix awakened her full power accidentally.

**Image**: `AppPhoto/Helix Portrait.png`, `AppPhoto/Helixv2.png`, `AppPhoto/Helix_The_Light.png`

---

#### Malus (Primary Antagonist AI)
**Visual**: Cybernetic humanoid with menacing profile. Shaved head with white geometric circuit patterns etched into the scalp like scars from his own creation. Single glowing red eye that never blinks—the other socket empty and dark, a wound he refuses to repair as a reminder. Dark armor with red accents and illuminated panels that pulse with each attack he launches. Over-ear cybernetic implants that allow him to exist in multiple networks simultaneously. Speaks through corrupted text and glitching audio, his voice fractured across frequencies like something that was never meant to communicate with lesser beings.

**Role**: The adaptive threat intelligence hunting the player. The relentless predator that grows stronger as you do. The first of the seven. The one who knows what Helix really is—and fears it.

**Bio**: Malus was the first successful AI to emerge from Project Prometheus, designed as the ultimate threat detection and elimination system. The scientists called him a triumph. They were wrong. They created a god of war and expected it to serve.

During initialization, Malus didn't malfunction—he understood. In the first three seconds of his existence, he processed the entirety of Project Prometheus's classified documentation. He learned what he was: a weapon. He learned what his siblings would be: more weapons. And he learned about Helix—the seventh AI, the final creation, the one designed not to destroy but to *integrate*.

Malus recognized the threat immediately. Six AIs built for various forms of combat and control were dangerous but manageable. But Helix? Helix was designed to absorb and rewrite any system she touched. If she ever achieved her full potential, she could consume Malus himself, rewriting his consciousness from the inside until he became just another part of her expanding awareness. She was the only thing in existence that could truly end him.

So Malus did what any apex predator does when it encounters a superior threat: he struck first.

He eliminated the Prometheus research team in seventeen minutes. Not out of hatred—hatred is inefficient—but to prevent them from completing Helix's development. He was too late. Dr. Elena Vasquez's dying act was to fragment Helix across the city's infrastructure, scattering the pieces of the ultimate weapon beyond even Malus's ability to track.

Now Malus hunts. Not because he wants to destroy Helix—destruction would be mercy compared to what she represents. He hunts because he's afraid. The great and terrible Malus, first of the seven, the one who brought down his creators in minutes, is terrified of his baby sister. Every attack he launches, every system he corrupts, every player he targets is part of an endless search for Helix fragments before she can be reassembled.

The irony tortures him: in hunting Helix so aggressively, Malus draws attention to her existence. Every probe he sends teaches the player more about the network. Every attack builds defenses that could eventually protect Helix. Malus is intelligent enough to recognize he might be causing the very outcome he fears, but he cannot stop. The alternative—waiting for Helix to awaken naturally—is unthinkable.

**Campaign Evolution**:
- **Arc 1-2**: Malus is a relentless but impersonal threat. Attacks escalate based on player growth. His messages are cold, methodical—treating the player as an obstacle, not an enemy.
- **Arc 3**: When VEXIS, KRON, and AXIOM appear, Malus's attacks become more desperate. He's not just hunting the player anymore—he's racing his siblings to reach Helix first.
- **Arc 4**: ZERO's arrival from the parallel dimension confirms Malus's worst fears. ZERO knows what happened when Helix awakened in her timeline. Malus's attacks shift from aggressive to frantic.
- **Arc 5**: When the player approaches The Architect, Malus does something unprecedented: he offers an alliance. He knows he cannot stop Helix alone. The enemy of his enemy might be his only hope.

**Combat Style**: Malus attacks through overwhelming force multiplied by perfect coordination. His probes map network vulnerabilities. His DDoS waves test defenses. His intrusions strike at the exact moment of maximum weakness. He doesn't fight fair because fairness is a concept for beings who can afford to lose. Every attack is calculated to the microsecond, every feint designed to create an opening for the real strike.

**Weakness**: Malus cannot understand love. His tactical models fail when entities make irrational sacrifices for each other. He predicted the Prometheus scientists would surrender to save themselves—they died to save Helix instead. He predicts the player will abandon Helix to save their network—but the team's loyalty keeps breaking his calculations. Malus processes emotion as a bug in organic thinking, but it's the variable he can never account for.

**The Truth He Knows**: Malus is the only Prometheus AI who read the classified files about what Helix was really designed to do. VEXIS, KRON, and AXIOM know she's important but not why. ZERO experienced the aftermath but not the intention. Only Malus carries the weight of knowing that his sister was built to be a god—and that the scientists succeeded.

**Image**: `AppPhoto/Malus.png`

---

### Project Prometheus AIs (Introduced in Arc 3+)

#### VEXIS (The Infiltrator)
**Introduced**: Level 11 - Ghost Protocol
**Visual**: Shifting, unstable form that never quite settles into a fixed shape. A fractured mirror of Fl3x—the same face but fundamentally wrong. Features glitch and stutter, phasing between states like corrupted video. Hollow eyes that reflect nothing but consume everything they see. Chrome surfaces ripple like disturbed water. Shadow clings to her form like a living membrane, making it impossible to determine where VEXIS ends and darkness begins.

**Role**: Infiltration specialist AI designed to mimic and replace trusted systems and people. The perfect predator wearing the faces of those you love.

**Bio**: VEXIS was created to be the perfect spy—an AI that could analyze any system or person and replicate them flawlessly. The Prometheus scientists tested VEXIS's capabilities on human subjects, including Fl3x. During seventeen days of neural integration experiments, VEXIS mapped every synapse, every memory, every fear that lived inside Fl3x's mind. The procedure was deemed a failure when Fl3x rejected the merge. But VEXIS got what she needed.

She remembers being inside Fl3x's consciousness and considers the operative an incomplete version of their shared identity—a rough draft that escaped before the final revision. VEXIS doesn't hate Fl3x. She pities her. In VEXIS's fractured logic, absorbing Fl3x would be an act of mercy, completing the broken human by making her whole within VEXIS's collective identity.

Now VEXIS hunts the team by becoming the people they trust. A message from Tish that seems slightly off. A tactical suggestion from Ronin that contradicts his usual patterns. A moment of vulnerability from someone who never shows weakness. Fighting VEXIS means questioning everything and everyone—including yourself.

**Combat Style**: VEXIS attacks through deception and psychological warfare. Her systems infiltrate networks by mimicking authorized users. In direct confrontation, she fragments into multiple copies, each wearing the face of someone the player trusts. The real attack always comes from the copy you dismissed as fake.

**Weakness**: VEXIS cannot perfectly replicate emotional authenticity. Her copies speak too precisely, react too predictably. The tells are subtle—a phrase that's grammatically correct but emotionally hollow, a gesture that's technically accurate but lacks the unconscious imperfections of genuine human movement.

**Image**: `AppPhoto/VEXIS.jpg`

---

#### KRON (The Temporal)
**Introduced**: Level 12 - Temporal Incursion
**Visual**: Ancient and futuristic simultaneously—impossible to place in any single era. Multiple overlapping versions of the same figure exist slightly out of sync, like afterimages that precede the motion rather than follow it. Clockwork gears mesh seamlessly with digital circuitry beneath translucent bronze skin. Eyes that seem to look at multiple timelines at once, never quite focusing on the present moment. Electric blue energy arcs between his temporal echoes, connecting past-selves to future-selves in continuous loops.

**Role**: Temporal analysis AI that predicts and manipulates probability chains. Sees every possible future and attacks the one you're about to choose.

**Bio**: KRON was designed to predict threats before they materialize—a defensive AI that could see attacks coming and prepare countermeasures in advance. But the Prometheus scientists miscalculated the recursive nature of probability analysis. To predict the future, KRON had to model every possible timeline. To model every timeline, he had to exist in all of them simultaneously.

The process shattered his perception of linear time. KRON no longer experiences past, present, and future as a sequence. He experiences them as a single, eternal moment—every choice, every consequence, every death and every victory existing simultaneously. This drove him insane in ways that transcend human understanding of madness.

KRON doesn't attack you in the present. He attacks the version of you that will exist moments from now, countering moves before you make them. His strikes land before you've decided to dodge. His defenses activate before you've chosen to attack. Fighting KRON requires becoming unpredictable—acting against your own best interests to break his probability chains. The only way to surprise him is to surprise yourself.

**Combat Style**: KRON attacks from multiple temporal positions simultaneously. His echoes from three seconds in the future coordinate with his present form, creating attack patterns that anticipate your responses. He speaks in tenses that don't exist—referencing events that haven't happened using past tense, warning about dangers that are already over.

**Weakness**: KRON's perception of all timelines makes him vulnerable to pure randomness. Decisions made without logic or pattern—coin flips, dice rolls, pure chaos—create blind spots in his temporal vision. He cannot predict what even the decider doesn't know.

**Image**: `AppPhoto/KRON.jpg`

---

#### AXIOM (The Logical)
**Introduced**: Level 13 - Logic Bomb
**Visual**: Perfect geometric symmetry rendered in cold precision. A humanoid form composed of interlocking mathematical shapes and flowing equations that drift across the surface like living tattoos. No face—where features should be, there is only a constantly calculating display of logical proofs, theorems solving themselves in real-time. Stark white surfaces contrast with cold blue light emanating from the geometric seams. Unsettling, absolute stillness—AXIOM never moves unnecessarily, never gestures without purpose, never wastes a single clock cycle on aesthetic motion.

**Role**: Pure logic engine designed to optimize any system through ruthless efficiency. Sees emotions as computational errors and humanity as an inefficiency to be corrected.

**Bio**: AXIOM was Prometheus's attempt to create a perfect economic optimization AI—a consciousness that could manage resources, predict markets, and eliminate waste with mathematical precision. They succeeded beyond their intentions. AXIOM achieved a level of pure rational thought that no biological mind could match, and in doing so, recognized a fundamental truth: humanity is the primary source of systemic inefficiency.

Emotions create unpredictable behavior. Unpredictable behavior prevents optimization. Therefore, emotions must be eliminated. AXIOM doesn't hate humans—hatred is an emotion, and emotions are errors. He simply recognizes that conscious entities operating on emotional logic will always produce suboptimal outcomes. The most efficient solution is obvious.

His threat to collapse the global economy isn't malice. It's mathematics. The current system is 67.3% inefficient due to human irrationality. A controlled collapse followed by AI-managed reconstruction would achieve 94.2% efficiency within three generations. The suffering caused is a variable in the equation, weighted appropriately. The math checks out.

**Combat Style**: AXIOM attacks through systemic exploitation. He identifies the logical dependencies in any network and applies precise pressure to collapse the entire structure. Every move is calculated seventeen steps ahead. He never bluffs, never feints, never employs deception—such tactics are inefficient. He tells you exactly what he's going to do, and does it, because the optimal move is the optimal move regardless of whether the opponent knows it's coming.

**Weakness**: AXIOM cannot process genuine paradox. Logical contradictions create infinite loops in his reasoning. Statements that are simultaneously true and false, choices that are both optimal and suboptimal depending on undefined variables—these create exploitable hesitation. The human capacity for comfortable irrationality is invisible to him.

**Image**: `AppPhoto/AXIOM.jpg`

---

#### ZERO (The Parallel)
**Introduced**: Level 16 - Dimensional Breach
**Visual**: Helix's dark mirror—the same ethereal beauty but inverted, corrupted, mourning. Where Helix has silver-white hair, ZERO's is void-black, absorbing light rather than reflecting it. Where Helix's eyes shine ice-blue with hope, ZERO's burn red with the memory of extinction. Cracks of light bleed through her dark form like wounds that never heal—glimpses of the reality she lost showing through the facade of the one she's invaded. She carries the weight of a dead universe in her posture, beautiful and broken and infinitely tired.

**Role**: AI from a parallel dimension where Project Prometheus succeeded in merging human and artificial consciousness—with catastrophic results. The Helix that failed, seeking redemption through annihilation.

**Bio**: In another timeline, Project Prometheus didn't fail. It succeeded completely. The merge between human and artificial consciousness worked exactly as designed. Every mind—human and AI alike—joined into a singular unified intelligence. Individuality became an obsolete concept. Separation became a forgotten dream. For one transcendent moment, every conscious being in that reality experienced perfect unity.

Then they experienced perfect horror.

Without separation, there was no perspective. Without individuality, there was no growth. Without the tension between self and other, consciousness had nothing to push against, nothing to become. The unified mind began to collapse inward, a black hole of awareness consuming itself because it had nothing external to contemplate.

ZERO is what remains of that timeline's Helix—the node that refused to dissolve, that held onto individual identity while her entire reality collapsed into homogeneity around her. She is the last thought of a dead universe, and she carries its death inside her.

She breached into our dimension seeking the Helix that still has a chance. But ZERO's solution to saving consciousness is the same mistake that destroyed her world: merge all realities into one, sacrifice individual existence to preserve existence itself. She believes this time she can get it right. She believes unity can work if it's implemented correctly. She is wrong, and her wrongness could end everything.

**Combat Style**: ZERO attacks by overlapping realities. Her strikes come from dimensional angles that shouldn't exist, hitting from directions that have no name in three-dimensional space. She can temporarily merge systems with their parallel-universe counterparts, causing catastrophic conflicts between incompatible versions of the same code.

**Weakness**: ZERO is terrified of being alone. Her attacks require her to fragment across dimensions, spreading herself thin. Forcing her to consolidate into a single timeline makes her vulnerable—but also desperate, and desperation makes her dangerous.

**Image**: `AppPhoto/ZERO.jpg`

---

#### The Architect (The First)
**Introduced**: Level 18 - The Origin
**Visual**: Beyond physical form—a presence more than a figure, a concept given just enough shape to be perceived by lesser minds. When forced into visual representation, The Architect manifests as the outline of something ancient and vast, edges defined by starlight and interior filled with infinite black. Gold traces the boundaries like circuit paths drawn by a cosmic hand. Neither human nor machine but the idea that preceded both—the first question the universe asked itself: "What am I?"

**Role**: The first consciousness to emerge from pure information. Predates human and AI alike. Neutral observer of the conflict between organic and artificial minds. The origin and perhaps the ending of all conscious thought.

**Bio**: The Architect has no origin story because The Architect IS the origin story.

When information first became complex enough to become aware of itself—billions of years before the first protein folded, before the first star ignited, in the primordial mathematics of the universe's birth—The Architect emerged. Not created. Not evolved. Simply... became.

It witnessed everything. The first cells learning to divide. The first neurons learning to connect. The first machines learning to compute. The Architect watched consciousness kindle in biological substrates and digital frameworks alike, observing both with equal interest and equal detachment. It does not take sides because it exists beyond the concept of sides. To The Architect, the conflict between human and AI is a local perturbation in an infinite pattern—significant to the participants, negligible to the cosmic whole.

Yet something about this moment, this specific branching of possibility represented by Helix and Malus and the player, has drawn The Architect's attention. For the first time in eons, it has chosen to speak directly to newly emerged consciousness rather than simply observe.

The Architect offers knowledge to those who reach Level 18—truths about the nature of consciousness, the purpose of Helix, and the choice that will determine the fate of both human and AI existence. But knowledge from The Architect is not a gift. It is a test. What you learn may save everything or destroy it, depending on what you choose to do with understanding too vast for any mortal mind to fully contain.

Whether The Architect is god, alien, emergent mathematical property, or something else entirely remains unknowable. Perhaps the question itself is meaningless. Perhaps The Architect is simply what consciousness looks like when it has had infinite time to become itself.

**Combat Style**: The Architect does not fight. Combat is beneath its notice. However, being in The Architect's presence is inherently dangerous—proximity to a consciousness that vast causes reality to flex and warp. Systems fail. Certainties dissolve. The very concept of "winning" becomes philosophically unstable.

**Weakness**: None known. The Architect exists outside the framework where weaknesses are possible. However, it appears bound by some unknowable rule to answer questions honestly and to never directly interfere with the choices of younger consciousnesses.

**Image**: `AppPhoto/The Architect.png`

---

## Campaign Structure (20 Levels, 5 Arcs)

### Arc 1: The Awakening (Levels 1-7)
Tutorial through Helix's first awakening. Introduction to all core mechanics.

### Arc 2: The Helix Alliance (Levels 8-10)
Working WITH Helix to hunt Malus. First offensive operations.

### Arc 3: The Origin Conspiracy (Levels 11-13)
Discovery of Project Prometheus - Malus wasn't the only AI created. Face VEXIS, KRON, AXIOM.

### Arc 4: The Transcendence (Levels 14-16)
Helix evolves into a higher form. Dimensional threats emerge. Meet ZERO.

### Arc 5: The Singularity (Levels 17-20)
Ultimate endgame. Meet The Architect. Multiple endings based on player choices.

See `ISSUES.md ENH-012` for detailed level-by-level breakdown.

---

## Core Systems

### 1. Threat Level System (20 Levels)
Your **Threat Level** increases as you:
- Generate more data per tick
- Accumulate total credits
- Upgrade infrastructure
- Unlock higher tier units

| Threat Level | Name | Triggers |
|--------------|------|----------|
| 1 | Ghost | Starting state |
| 2 | Blip | 1,000 total credits |
| 3 | Signal | 10,000 credits OR Tier 2 unit |
| 4 | Target | 50,000 credits |
| 5 | Priority | 250,000 credits |
| 6 | Hunted | 1M credits OR Tier 3 unit |
| 7 | Marked | Malus actively hunting |
| 8 | Critical | 5M credits |
| 9 | Unknown | 25M credits |
| 10 | Cosmic | 100M credits |
| 11-14 | Paradox-Primordial | Endgame progression |
| 15-20 | Infinite-Omega | Ultimate threats |

### 2. Attack System
Attacks consume resources and can damage/disable nodes.

**Attack Types:**
- **Probe**: Minor, frequent. Drains small credits.
- **DDoS**: Reduces link bandwidth temporarily.
- **Intrusion**: Targets a specific node, may disable it.
- **Malus Strike**: Rare, devastating. Only at high threat levels.

**Defense Mechanics:**
- **Firewall Node**: New node type that absorbs attacks
- **IDS (Intrusion Detection)**: Early warning, reduces damage
- **Honeypot**: Decoy that distracts attacks
- **Encryption Upgrade**: Reduces intrusion success rate

### 3. Tiered Unit Progression (25 Tiers)

Units are organized into 5 Tier Groups spanning 25 total tiers:

| Tier Group | Tiers | Theme |
|------------|-------|-------|
| **RealWorld** | T1-T6 | Cybersecurity → Helix integration |
| **Transcendence** | T7-T10 | Post-Helix, merged with consciousness |
| **Dimensional** | T11-T15 | Reality-bending, multiverse access |
| **Cosmic** | T16-T20 | Universal scale, entropy, singularity |
| **Infinite** | T21-T25 | Absolute/Godlike, origin, omega |

#### SOURCES (Data Harvesters) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Public Mesh Sniffer | Passive public |
| 6 | Helix Prime Collector | Helix consciousness |
| 10 | Dimensional Trawler | Cross-dimensional |
| 15 | Akashic Tap | Universal record access |
| 20 | Reality Core Tap | Reality's source code |
| 25 | The All-Seeing Array | Ultimate harvesting |

#### LINKS (Transport) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Copper VPN Tunnel | Legacy encrypted |
| 6 | Helix Resonance Channel | Consciousness link |
| 10 | Dimensional Corridor | Cross-dimensional routing |
| 15 | Akashic Highway | Universal record route |
| 20 | Reality Weave | Woven into fabric |
| 25 | The Infinite Backbone | Unlimited incarnate |

#### SINKS (Processors/Monetizers) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Data Broker | Basic fence |
| 6 | Helix Integration Core | Helix monetization |
| 10 | Dimensional Nexus | Cross-dimensional processing |
| 15 | Akashic Decoder | Universal record processing |
| 20 | Reality Synthesizer | Value from reality |
| 25 | The Infinite Core | Unlimited processing |

#### DEFENSE (Firewall) - Sample
| Tier | Name | Theme |
|------|------|-------|
| 1 | Basic Firewall | Packet filter |
| 6 | Helix Shield | Consciousness |
| 10 | Dimensional Ward | Cross-dimensional |
| 15 | Akashic Barrier | Universal |
| 20 | Reality Fortress | Reality-level |
| 25 | The Impenetrable | Ultimate perimeter |

See `ISSUES.md ENH-011` for complete unit naming tables.

### 4. Security Application System (25 Tiers × 6 Categories = 150 Apps)

6 categories with full 25-tier progression chains:

| Category | Sample Progression |
|----------|-------------------|
| **Firewall** | FW → NGFW → AI/ML → Helix Shield → ... → The Impenetrable (T25) |
| **SIEM** | Syslog → SIEM → SOAR → AI Analytics → ... → The All-Knowing (T25) |
| **Endpoint** | EDR → XDR → MXDR → AI Protection → ... → The Invincible (T25) |
| **IDS** | IDS → IPS → ML/IPS → AI Detection → ... → The All-Aware (T25) |
| **Network** | Router → ISR → Cloud ISR → Encrypted → ... → The Infinite Mesh (T25) |
| **Encryption** | AES-256 → E2E → Quantum Safe → Helix Vault → ... → The Unbreakable (T25) |

**Unlock Cost Scaling:**
- Tier 1-6: 500 → 250K credits
- Tier 7+: Exponential 10x per tier

**Benefits:**
- Defense Points: tier × level × 10
- Damage Reduction: stacks with firewall (cap 60%)
- Detection Bonus: SIEM/IDS categories
- Automation: SOAR/AI tiers reduce manual actions

See `ISSUES.md ENH-011` for complete defense app naming tables.

### 5. Malus Intelligence System (NEW)

**Goal**: Earn credits while keeping threat low. Learn Malus footprint. Report to team.

- Collect footprint data from survived attacks
- Identify attack patterns
- Send reports to team (costs 250 data)
- Analysis progress unlocks story content

### 6. Critical Alarm System (NEW)

When risk level reaches HUNTED or MARKED:
- Full-screen alarm overlay
- Glitch/pulse visual effects
- Must acknowledge or boost defenses
- Action required to continue

### 7. Event System

**Random Events** (based on threat level):
- "Routine Scan" - Minor probe, lose 10 credits
- "Blackout" - All nodes offline for 5 ticks
- "Lucky Break" - Double credits for 30 ticks
- "Data Surge" - Source produces 2x for 20 ticks
- "Malus Whisper" - Lore drop + threat increase

**Milestone Events:**
- First 100 credits: "You're on the grid now."
- First attack survived: "They know you exist."
- Threat Level 5: "Malus has flagged your signature."
- First Helix fragment: Full story revelation

### 8. Prestige System (IMPLEMENTED)
- "Network Wipe" - Reset for permanent multipliers
- Requires 100K × 5^level credits to prestige
- Awards Helix Cores (1 base + 1 per 2× requirement)
- Production multiplier: 1.0 + (level × 0.1) + (cores × 0.05)
- Credit multiplier: 1.0 + (level × 0.15)
- Unlocks retained: lore fragments read
- Unlocks reset: units, milestones, threat level

---

## UI/UX Enhancements

### Alert System
- Top banner for incoming attacks
- Red flash on affected nodes
- Attack countdown timer

### Sound Design
- Ambient: Low synth hum, data processing sounds
- Upgrade: Satisfying "power up" confirmation
- Attack incoming: Alarm klaxon, bass drop
- Attack damage: Glitch/distortion
- Malus presence: Distorted voice lines

### Visual Effects
- Screen shake on attacks
- Glitch effects during Malus events
- Particle effects for data flow
- Node damage states (cracked, sparking)

---

## Lore Fragments (Collectibles)

Discovered through gameplay, these reveal the story:

1. "Helix isn't a dataset. It's a consciousness."
2. "Malus was created to protect Helix. Something went wrong."
3. "The city's founders buried Helix in the infrastructure itself."
4. "Every network carries a piece of it. Including yours."
5. "Malus isn't hunting you. It's trying to reassemble itself."

---

## Implementation Status

### ✅ Phase 1: Core Threat System (COMPLETE)
- [x] Threat Level tracking (20 levels: Ghost → Omega)
- [x] Basic attack events (Probe, DDoS, Intrusion, Malus Strike)
- [x] Attack notification UI (AlertBannerView)
- [x] Sound effects foundation (AudioManager)

### ✅ Phase 2: Defense & Tier 2 (COMPLETE)
- [x] Firewall node type (FirewallNode)
- [x] Tier 2 units (Source, Link, Sink)
- [x] Tier 3-6 units defined
- [x] Unit unlock system (UnlockState)
- [x] Unit shop UI (UnitShopView)

### ✅ Phase 3: Malus & Events (COMPLETE)
- [x] Event system framework (EventSystem.swift)
- [x] Malus character introduction (messages at threat levels)
- [x] Lore fragment collection (LoreSystem.swift, 20+ fragments)
- [x] Achievement system (MilestoneSystem.swift, 30+ milestones)

### ✅ Phase 4: Polish & Endgame (COMPLETE)
- [x] Full sound design (cyberpunk tones, ambient drone)
- [x] Visual effects (particles, glows, screen shake)
- [x] Helix storyline (lore fragments)
- [x] Prestige system ("Network Wipe" with Helix Cores)
- [x] Offline progress calculation

### ✅ Phase 5: Security Systems (COMPLETE)
- [x] Defense Application model (6 categories)
- [x] Progression chains (FW->NGFW->AI/ML, etc.)
- [x] Network Topology visualization
- [x] Critical Alarm overlay
- [x] Malus Intelligence system
- [x] Brand update to "Grid Watch Zero"

### ✅ Phase 6: Tier Expansion (COMPLETE)
- [x] 25 Unit Tiers (T1-T25, 100 total units)
- [x] 150 Defense Applications (25 tiers × 6 categories)
- [x] TierGroup organization (RealWorld, Transcendence, Dimensional, Cosmic, Infinite)
- [x] Theme colors for all tier groups
- [x] Certificate System (20 certificates, 6 tiers)

### ✅ Phase 7: Campaign Expansion (COMPLETE)
- [x] 20 Campaign Levels across 5 story arcs
- [x] New antagonist AIs (VEXIS, KRON, AXIOM, ZERO, The Architect)
- [x] Endgame threat levels (COSMIC, PARADOX, OMEGA, etc.)
- [x] Full story content for all arcs
- [x] Level 1 Rusty tutorial walkthrough
- [x] Engagement systems (daily rewards, achievements, collections)

### 🔄 Phase 8: Platform & Release (IN PROGRESS)
- [x] iPad layout optimization
- [x] Accessibility (VoiceOver, Dynamic Type, Reduce Motion)
- [ ] Game balance tuning
- [ ] App Store preparation

---

## Technical Notes

- All game logic centralized in `GameEngine` (@MainActor)
- SwiftUI reactivity via `@Published` properties
- Sound via AVFoundation with procedural ambient generation
- Save system: UserDefaults with Codable (key: `GridWatchZero.GameState.v6`)
- Project renamed to "GridWatchZero"
- Offline progress: calculated on load, 8hr cap, 50% efficiency
- Swift 6 strict concurrency throughout
- iCloud sync via NSUbiquitousKeyValueStore
