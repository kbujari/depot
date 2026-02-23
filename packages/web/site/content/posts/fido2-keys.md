---
title: "FIDO2 hardware keys as your root of trust"
date: "2026-02-11"
---

Storing private keys as FIDO2 discoverable secrets on hardware devices like a YubiKey is really convenient while keeping great security.
One example of this is SSH keys:
`*-sk` type keys like `ed25519-sk` or `ecdsa-sk` keep a secret key in the hardware device,
and short private key "shim" on disk,
treating the hardware key as a second factor of authentication.

Personally, the more interesting use case is to skip the shim stored on disk and keep the entire secret key on the hardware.
This is called a *resident key* and does not require any state on the local machine to authenticate.
Unlike storing keys in the PIV slot of a Yubikey,
which requires custom software like [yubikey-ssh-agent](https://github.com/FiloSottile/yubikey-agent) on the host to retrieve,
FIDO2 support is built in to openssh (since 8.2) and systemd (systemd-cryptenroll)!

Having builtin support with modern SSH is especially convenient,
for authenticating from hosts you might not use every day.
Something like yubikey-ssh-agent is probably not installed on normal systems,
but the regular ssh-agent distributed with openssh >8.2 is much more likely to work.
Of course, I would only use this on "semi-trusted" machines,
where I am not paranoid of key loggers or weird memory shenanigans.

I replaced my per-machine SSH keys with 3 `ed25519-sk` keys stored on a few keys I had laying around.
This lets me access my internet-facing servers without managing keys on each host,
and each SSH server only has to authorize these 3 keys to know its me.
When I take my laptop around I can just grab a key and leave the "backups" at home,
since any of them work for authentication.

# Followup on full disk encryption

Given `systemd-cryptenroll` [supports FIDO2 tokens](https://wiki.archlinux.org/title/Systemd-cryptenroll#FIDO2_tokens),
I think proper disk encryption is worth exploring again.
Previously, I disabled it since entering passwords for both LUKS and my user account felt tedious,
and storing a key in the machines TPM without a PIN didn't feel very secure,
since I didn't have to authenticate myself in any way.

With disk encryption keyed by a passphrase as well as a hardware token,
I can have the security of full disk encryption with the convenience of fast authentication.
Buying hardware keys for each device seems a bit pricey,
so I feel re-using hardware keys across machines would be a worthwhile compromise.

I'm also experimenting with bootstrapping identities + encryption on some local servers I run at home,
where otherwise stateless machines can decrypt secrets on boot using their hardware key,
and unplugging the key makes the hosts dumb again,
but I'll save that for another post 👀.
