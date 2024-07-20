<script lang="ts">
	import Github from "~icons/mdi/github";
</script>

<svelte:head>
	<title>Scuba Diving Companion</title>
</svelte:head>
<div class="h-full">
	<div class="container flex flex-col mx-auto items-center pt-5">
		<div class="space-y-10 text-center flex items-center">
			<div class="card p-8 max-w-2xl">
				<header>
					<h3 class="h3" data-toc-ignore>Sea Life IDentification App</h3>
					<img src="/sea-life-id-screenshot-identify.png" class="pt-4 rounded-md w-3/4 mx-auto" alt="sea-life-id app" />
				</header>
				<div class="p-4 space-y-4">
					<article>
						<p class="text-center mx-6">
							After your dive, automatically identify marine life from your underwater photos and
							videos.
						</p>
					</article>
				</div>
				<hr class="opacity-50" />
				<footer class="p-4 flex justify-start items-center space-x-4">
					<div class="flex-auto flex justify-between items-center">
						<p class="mb-0 text-white-50">
							<a
								href="https://play.google.com/store/apps/details?id=com.scubacompanion.underwatervideotagging&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1"
								><img
									style="max-width:150px;"
									class="img-fluid"
									alt="Get it on Google Play"
									src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
								/></a
							>
						</p>
						<a target="_blank" href="https://github.com/francoislanc/sea-life-identification" class="btn-icon variant-soft-secondary"><Github /></a>

					</div>
				</footer>
			</div>
		</div>
	</div>
</div>

<style lang="postcss">
</style>
