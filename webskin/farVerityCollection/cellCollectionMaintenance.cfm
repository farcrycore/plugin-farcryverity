<cfsetting enablecfoutputonly="true" />
<!----------------------------------------
ENVIRONMENT
----------------------------------------->
<cfparam name="url.module" type="string" />

<cfoutput>
<a href="##" onclick="$('SelectedObjectID#Request.farcryForm.Name#').value='#stobj.objectid#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value='create';forms.#Request.farcryForm.Name#.submit();" title="Create Collection">C</a>
<a href="##" onclick="$('SelectedObjectID#Request.farcryForm.Name#').value='#stobj.objectid#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value='deleteCollection';forms.#Request.farcryForm.Name#.submit();" title="Delete Collection">D</a>
<a href="##" onclick="$('SelectedObjectID#Request.farcryForm.Name#').value='#stobj.objectid#';$('FarcryFormSubmitButtonClicked#Request.farcryForm.Name#').value='purge';forms.#Request.farcryForm.Name#.submit();" title="Purge Collection">P</a>
</cfoutput>

<cfsetting enablecfoutputonly="false" />