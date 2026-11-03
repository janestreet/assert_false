@@ portable

(** An [assert false] replacement, which ought to be easier to locate when raised in
    production.

    A call site is intended to look like
    {[
      Assert_false.bug ~__LOC__ "reason this cannot happen"
    ]}
    where "reason this cannot happen" both (1) documents why this branch is believed to be
    unreachable, and (2) has enough entropy to uniquely identify the call site in grep
    results.

    The resulting exception will look like
    {v
      (Failure "BUG: reason this cannot happen at filename.ml:325:58")
    v}
    so this should be enough information to uniquely identify the call site.

    When initially converting over [assert false] calls automatically, maybe just punt on
    (1) and ensure (3) by picking the string argument at random. An easy way to produce
        such a string is to call [uuid -v 4], and just use the first 8 characters.

    [__LOC__] is a built-in OCaml macro that expands into the source location, but without
    directory information.

    This is an improvement on [assert false], since grepping for a UID string is easier
    that jumping to a source code position when you're debugging during an emergency. The
    latter requires you to find the correct hg revision first, and update to it.

    The definition is marked [@cold] so that it won't be inlined, and also so that it is
    less likely to tip the inlining scales at the call site. *)
val bug : __LOC__:string -> string -> _ @ unique

(** Like {!val:bug} but uses [%call_pos] so you can elide the __LOC__ argument.

    This function also shows the entire path of file in the repo rather than just the
    basename. *)
val bug' : here:[%call_pos] -> string -> _ @ unique
