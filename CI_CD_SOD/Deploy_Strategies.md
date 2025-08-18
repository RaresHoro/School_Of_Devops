# Deployment Strategies

When delivering software using CI/CD, **how** you release changes to production is just as important as the pipeline itself.
Different **deployment strategies** balance speed, safety, and risk differently.

---

## 1. Recreate Deployment

- **How it works:** Stop the old version completely, then start the new version.
- **Pros:** Simple, no overlap.
- **Cons:** Causes downtime until the new version is running.
- **Use case:** Small apps, non-critical services, or when downtime is acceptable.

---

## 2. Rolling Deployment

- **How it works:** Gradually replace old versions with new ones, one batch of servers/pods at a time.
- **Pros:** No downtime, resources reused, safer than recreate.
- **Cons:** Harder rollback if something goes wrong mid-way.
- **Use case:** Standard approach for web apps and microservices.

---

## 3. Blue-Green Deployment

- **How it works:** Two identical environments exist:
  - **Blue** = current version
  - **Green** = new version
- Deploy new version to **Green**. Once verified, switch traffic from Blue → Green.
- **Pros:** Instant rollback (switch back), zero downtime.
- **Cons:** Requires double infrastructure (costly).
- **Use case:** High-availability systems where downtime is unacceptable.

---

## 4. Canary Deployment

- **How it works:** Release the new version to a small percentage of users, monitor, then gradually roll out to more users.
- **Pros:** Real-world testing with minimal risk, easy rollback.
- **Cons:** More complex monitoring and traffic routing.
- **Use case:** Large-scale apps, user-facing services where errors affect many users.

---

## 5. Shadow Deployment (a.k.a. Dark Launching)

- **How it works:** New version receives **real production traffic**, but responses are discarded (users still see the old version).
- **Pros:** Test with live traffic safely, no impact on users.
- **Cons:** Doubles load on infrastructure, complex setup.
- **Use case:** Testing performance, load handling, or new features before rollout.

---

## 6. A/B Testing Deployment

- **How it works:** Route traffic to two (or more) versions simultaneously, compare results (e.g., conversion rates, performance).
- **Pros:** Great for feature experiments, data-driven decisions.
- **Cons:** Needs strong monitoring and traffic-splitting logic.
- **Use case:** Testing new features, UI/UX changes, or business logic.

---

## 7. Feature Flags (Toggle Releases)

- **How it works:** Deploy code with new features **disabled by default**. Enable features gradually with flags (config switch).
- **Pros:** Instant rollbacks, gradual rollout, safer experimentation.
- **Cons:** Can add technical debt if flags aren’t cleaned up.
- **Use case:** Progressive feature releases, continuous deployment.

---

## 8. Choosing a Strategy

- **Small projects / tolerable downtime:** Recreate
- **Standard, safe deployments:** Rolling
- **High-availability critical systems:** Blue-Green or Canary
- **Testing in production safely:** Shadow, A/B testing, Feature Flags

---
