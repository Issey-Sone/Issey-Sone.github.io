# On the Borel–Cantelli Lemma

*Jun 2026 · math, statistics*

The Borel–Cantelli lemmas are two of the most quietly useful results in
probability theory. They let us say something about whether infinitely many
events occur, using nothing more than the sum of their probabilities. This post
walks through both directions and the asymmetry between them.

## Setup

Let $(A_n)_{n \geq 1}$ be a sequence of events on a probability space
$(\Omega, \mathcal{F}, \mathbb{P})$. We are interested in the event that
infinitely many of the $A_n$ occur, written

$$\{A_n \text{ i.o.}\} = \bigcap_{n=1}^{\infty} \bigcup_{k \geq n} A_k.$$

A point $\omega$ belongs to this set exactly when it lies in $A_k$ for
arbitrarily large $k$ — that is, the events never stop happening.

## The First Lemma

The first Borel–Cantelli lemma requires no independence at all.

> If $\sum_{n=1}^{\infty} \mathbb{P}(A_n) < \infty$, then
> $\mathbb{P}(A_n \text{ i.o.}) = 0$.

The proof is a one-liner. For every $n$,

$$\mathbb{P}(A_n \text{ i.o.}) \leq \mathbb{P}\left(\bigcup_{k \geq n} A_k\right)
\leq \sum_{k \geq n} \mathbb{P}(A_k),$$

and the tail of a convergent series goes to $0$. Done.

## The Second Lemma

The converse is *false* in general, which is the surprising part. We need
independence to recover it.

> If the $A_n$ are independent and $\sum_{n=1}^{\infty} \mathbb{P}(A_n) = \infty$,
> then $\mathbb{P}(A_n \text{ i.o.}) = 1$.

The trick is to bound the complement using $1 - x \leq e^{-x}$:

$$\mathbb{P}\left(\bigcap_{k=n}^{m} A_k^c\right)
= \prod_{k=n}^{m} (1 - \mathbb{P}(A_k))
\leq \exp\left(-\sum_{k=n}^{m} \mathbb{P}(A_k)\right) \to 0.$$

Since the divergence makes this probability vanish, the events must recur
infinitely often with probability one.

## Why Independence Matters

Consider a single event $A$ with $0 < \mathbb{P}(A) < 1$, and set
$A_n = A$ for all $n$. Then $\sum \mathbb{P}(A_n) = \infty$, but

$$\mathbb{P}(A_n \text{ i.o.}) = \mathbb{P}(A) < 1.$$

The sum diverges, yet the events do not recur with certainty — because they are
maximally dependent. This is exactly the gap the independence hypothesis closes.

![A 2-simplex of probability distributions over three outcomes](https://placehold.co/480x240/f4f4f4/333?text=probability+simplex)

## Further Reading

For a careful treatment, see the chapter on independence in David Williams'
[*Probability with Martingales*](https://www.cambridge.org/core/books/probability-with-martingales/). The
zero–one law that underlies the second lemma is worth studying on its own.
