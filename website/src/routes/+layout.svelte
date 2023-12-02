<script lang="ts">
	import '../app.postcss';
	import { AppShell } from '@skeletonlabs/skeleton';
	import Github from "~icons/mdi/github";
</script>

<!-- App Shell -->
<AppShell>
	<svelte:fragment slot="header">
		<div class="h-[200px] w-full">
			<img
				class="w-full h-[200px] object-cover opacity-50"
				src="/background-main.jpg"
				alt="scuba diving companion"
			/>
			<div class="absolute top-0 p-5">
				<h1 class="text-white opacity-75 text-4xl font-bold">Scuba Diving Companion</h1>
				<h2 class="text-white opacity-60 text-sm">Tools for the scuba diving community</h2>
				<a target="_blank" href="https://github.com/francoislanc/scubadivingcompanion" class=" mt-5 btn-icon variant-ghost opacity-60"><Github /></a>
			</div>
			
		</div>
	</svelte:fragment>
	<!-- Page Route Content -->
	<slot />
</AppShell>
