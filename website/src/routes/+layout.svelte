<script lang="ts">
	import '../app.postcss';
	import { AppShell } from '@skeletonlabs/skeleton';
	import Github from "~icons/mdi/github";
</script>

<!-- App Shell -->
<AppShell>
	<svelte:fragment slot="header">

	</svelte:fragment>
	<!-- Page Route Content -->
	<slot />
</AppShell>
